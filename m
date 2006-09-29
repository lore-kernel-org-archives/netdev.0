From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 14:41:09 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609291430130.7553@d.namei>
References: <36282A1733C57546BE392885C0618592015CF2BE@chaos.tcs.tcs-sec.com>
 <451D4A51.4000603@hp.com> <Pine.LNX.4.64.0609291247170.6007@d.namei>
 <451D5B3F.70206@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Joshua Brindle <method@gentoo.org>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, kmacmillan@mentalrootkit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:36015 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1161387AbWI2SlM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 14:41:12 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <451D5B3F.70206@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Sep 2006, Paul Moore wrote:

> James Morris wrote:
> > Ok, can you please explain it further?
> > 
> > i.e. show me what the policy looks like, exactly what the user is trying 
> > to achieve, and explain what happens to each packet exactly in terms of 
> > labeling on the input and output paths.
> 
> All right, here is my take on it, perhaps Venkat can chime in too.

Thanks, that cleared up many things, but how does this interact with 
CONNSECMARK?

Please provide some example iptables rules, SELinux policy statements, 
racoon config and netlabel config.  I need to understand exactly what 
happens to each packet in, say, an FTP session and how you envisage the 
configuration.

Here's a sample scenario for the above (let me know if this is not how 
you expect this to be used):

Say that the SA is labeled "secret" and you have two FTP clients 
connecting to a server via xinetd on this SA.  Each client additionally 
labels their packets via CIPSO as secret:c1 and secret:c2 respectively.  
xinetd launches an FTP server for each at the correct level.



- James 
-- 
James Morris
<jmorris@namei.org>
