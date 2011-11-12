From: Julian Anastasov <ja@ssi.bg>
Subject: Re: send/receive data via eth0/1 external loop ?
Date: Sat, 12 Nov 2011 20:31:13 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1111122028420.2562@ja.ssi.bg>
References: <104297899.1282710.1321058833510.JavaMail.fmail@mwmweb017>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Roland Kletzing <devzero@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:34865 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751757Ab1KLSas (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Nov 2011 13:30:48 -0500
In-Reply-To: <104297899.1282710.1321058833510.JavaMail.fmail@mwmweb017>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 12 Nov 2011, Roland Kletzing wrote:

> Hello,
> i`m searching for a while now, but i did not find a solution, so forgive when
> i`m (as a user) asking for expert help here.
> 
> I want to do some network stress/burn-in and quality/reliability testing,
> i.e. i want to send/receive large amounts of data trough the systems network
> interfaces without the need of hogging the net or other systems.
> 
> so, that test should run "loopback", i.e. connecting eth0+1 via crossover cable
> or via locally attached switch. I don`t want to use a second system for that.
> 
> testing at ip/tcp level would be favourable , but raw eth level would be also fine.
> 
> But how ?
> What appears simple on a first view, seems to be difficult.... :(
> 
> All i came across is this report:
> http://www.zyztematik.com/?p=10
> and this description of a patch:
> http://www.ssi.bg/~ja/send-to-self.txt
> 
> Does somebody know a proper way of achieving this without patching the
> kernel ?

	You can use accept_local flag and rule with pref 0:

http://marc.info/?l=linux-netdev&m=125983955627148&w=2

Regards

--
Julian Anastasov <ja@ssi.bg>
