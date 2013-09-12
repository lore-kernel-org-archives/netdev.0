From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: ip l2tp - suspected defect using IPv6 local/remote addresses
Date: Thu, 12 Sep 2013 14:19:01 +0100
Message-ID: <1378991941.1531.5.camel@bwh-desktop.uk.level5networks.com>
References: <CAG2uBVfwNOj_jKvaHV_66qrrBU5adDoqDWMvV7seNWfsG4RVAQ@mail.gmail.com>
	 <CAEwTi7Qo8=X=v51_1y3JMQnbG3xBQYRb9YRePFh6KfYmb_Y0-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Loughridge <jeffl@alumni.duke.edu>, <netdev@vger.kernel.org>
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:57211 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754326Ab3ILPxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 11:53:53 -0400
In-Reply-To: <CAEwTi7Qo8=X=v51_1y3JMQnbG3xBQYRb9YRePFh6KfYmb_Y0-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-12 at 11:20 +0100, James Chapman wrote:
> On 11 September 2013 19:52, Jeff Loughridge <jeffl@alumni.duke.edu> wrote:
> >
> > Using IPv6 address as L2TPv3 endpoints doesn't seem to work in
> > iproute2 3.11. I see a cosmetic defect in the output of 'ip l2tp show
> > tunnel'. In addition, I can't get tunnels to function with UDP or IP
> > encapsulation.
> >
> > root@debian:~# ip l2tp add tunnel tunnel_id 3000 peer_tunnel_id 4000
> > encap udp local a::1 remote a::2 udp_sport 5000 udp_dport 6000
> > root@debian:~# ip l2tp add session tunnel_id 3000 session_id 1000
> > peer_session_id 2000
> > root@debian:~# ip l2tp show tunnel
> > Tunnel 3000, encap UDP
> >   From 127.0.0.1 to 127.0.0.1
> >   Peer tunnel 4000
> >   UDP source / dest ports: 5000/6000
> > root@debian:~#
> 
> You'll need a 3.5 or later kernel for L2TP over IPv6. I see you are
> using 3.2. Are you using a version of iproute2 which is not matched to
> your kernel?
[...]

The iproute2 version number only indicates which kernel features it
supports; it is supposed to be backward-compatible.  And it really
should not silently fail like this, although this may well be a bug in
the API that can't be fixed in userland...

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
