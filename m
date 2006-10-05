From: James Morris <jmorris@namei.org>
Subject: RE: [PATCH 1/3] Fix for IPsec leakage with SELinux enabled - V.03
Date: Thu, 5 Oct 2006 19:05:48 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610051903500.26861@d.namei>
References: <36282A1733C57546BE392885C0618592015CFB65@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, paul.moore@hp.com,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	eparis@redhat.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:62664 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932413AbWJEXFv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 19:05:51 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <36282A1733C57546BE392885C0618592015CFB65@chaos.tcs.tcs-sec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 5 Oct 2006, Venkat Yekkirala wrote:

> > We're trying to fill the flow cache here.  In the case where we'd
> > have a match in both the sub-policy and main table, I think the
> > sub-policy is supposed to take precedence, and if you fail to get
> > this sub-policy you should fail the entire lookup.
> 
> Which is what's happening here correct?

Yes, the patch is correct for this.

The way sub-policy is used is during Mobile IP, where you have multiple 
policies composed, so it wouldn't make sense for one of the policies to be 
rejected and the other allowed and for packets to flow.


- James
-- 
James Morris
<jmorris@namei.org>
