From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] Fix for IPsec leakage with SELinux enabled - V.02
Date: Mon, 2 Oct 2006 20:00:22 +0400
Message-ID: <20061002160021.GA8823@2ka.mipt.ru>
References: <20060930111521.GA646@2ka.mipt.ru> <Pine.LNX.4.64.0609301035020.26766@d.namei> <20060930144018.GA16918@2ka.mipt.ru> <Pine.LNX.4.64.0609301044090.26813@d.namei> <Pine.LNX.4.64.0610010203440.8658@d.namei> <20061002112050.GA772@2ka.mipt.ru> <Pine.LNX.4.64.0610020919050.9400@d.namei> <20061002134200.GA20441@2ka.mipt.ru> <Pine.LNX.4.64.0610021004180.9739@d.namei> <Pine.LNX.4.64.0610021020390.9909@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:26014 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S964894AbWJBQB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 12:01:27 -0400
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0610021020390.9909@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 02, 2006 at 10:27:13AM -0400, James Morris (jmorris@namei.org) wrote:
> Updated version of the patch, which return directly after a flow cache 
> lookup error in xfrm_lookup rather than returing via the cleanup path 
> (which was causing a spurious dst_release).
> 
> This works for me, although I never saw the oops with the old patch.
> 
> Evgeniy, let me know if this fixes the oops you're seeing.

With enabled selinux in enforcing mode I can not even get messages to
racoon, i.e. tcpdump sees first message of the daemon, but racoon log
(with a lot of -d) is not changed.
With permissive mode everything works fine.

It is possible that it is 2.6.18 only problem though, I will try
previous kernels.

-- 
	Evgeniy Polyakov
