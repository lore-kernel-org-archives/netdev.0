From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] Fix for IPsec leakage with SELinux enabled
Date: Mon, 2 Oct 2006 10:05:22 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610021004180.9739@d.namei>
References: <20060925120519.GA19010@2ka.mipt.ru> <Pine.LNX.4.64.0609300037460.12011@d.namei>
 <Pine.LNX.4.64.0609300110190.12422@d.namei> <20060930111521.GA646@2ka.mipt.ru>
 <Pine.LNX.4.64.0609301035020.26766@d.namei> <20060930144018.GA16918@2ka.mipt.ru>
 <Pine.LNX.4.64.0609301044090.26813@d.namei> <Pine.LNX.4.64.0610010203440.8658@d.namei>
 <20061002112050.GA772@2ka.mipt.ru> <Pine.LNX.4.64.0610020919050.9400@d.namei>
 <20061002134200.GA20441@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:9160 "EHLO
	mail6.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932353AbWJBOF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 10:05:26 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061002134200.GA20441@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Oct 2006, Evgeniy Polyakov wrote:

> Probably reference counter is inside freed object...

I think I know what it is (xfrm_lookup needs to just return on flow cache 
lookup failure, not goto error and free the dst).  Patch forthcoming.




- James
-- 
James Morris
<jmorris@namei.org>
