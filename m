From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Fix for IPsec leakage with SELinux enabled - V.03
Date: Thu, 05 Oct 2006 14:47:10 -0700 (PDT)
Message-ID: <20061005.144710.102574081.davem@davemloft.net>
References: <36282A1733C57546BE392885C0618592015CFB65@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, paul.moore@hp.com, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, sds@tycho.nsa.gov, eparis@redhat.com,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:34719
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932254AbWJEVrN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 17:47:13 -0400
To: vyekkirala@TrustedCS.com
In-Reply-To: <36282A1733C57546BE392885C0618592015CFB65@chaos.tcs.tcs-sec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Date: Thu, 5 Oct 2006 17:27:03 -0400 

> May be James can help me understand this; when exactly would a sub-policy
> be "notice"d here? What does "put the whole thing together" mean?

The code in xfrm_lookup() which does a flow cache lookup,
and then if it finds it has obtained a sub-policy it tries
to do an explicit main table policy lookup.  The sub-policy
and the main table policy thus found are "put together" to
form the full route.
