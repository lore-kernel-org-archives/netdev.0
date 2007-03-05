From: "Venkat Yekkirala" <vyekkirala@trustedcs.com>
Subject: RE: [PATCH] Add xfrm policy change auditing to pfkey_spdget
Date: Mon, 5 Mar 2007 09:59:14 -0600
Message-ID: <001601c75f3f$394d8af0$cc0a010a@tcssec.com>
References: <1172861484.31047.26.camel@localhost.localdomain>
Reply-To: <vyekkirala@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <jmorris@namei.org>,
	"Venkat Yekkirala" <vyekkirala@tcsfw4.tcs-sec.com>,
	<cxzhang@watson.ibm.com>, <sds@tycho.nsa.gov>
To: "'Eric Paris'" <eparis@parisplace.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:15903 "EHLO
	tcsfw4.tcs-sec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933575AbXCEP7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 10:59:37 -0500
In-Reply-To: <1172861484.31047.26.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> pfkey_spdget neither had an LSM security hook nor auditing for the
> removal of xfrm_policy structs.  The security hook was added 
> when it was
> moved into xfrm_policy_byid instead of the callers to that function by
> my earlier patch and this patch adds the auditing hooks as well.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>
Acked-by: Venkat Yekkirala <vyekkirala@trustedcs.com>  
