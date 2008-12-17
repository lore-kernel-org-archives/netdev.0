From: "Tvrtko A. Ursulin" <tvrtko@ursulin.net>
Subject: skge performance sensitivity (WAS: Bonding gigabit and fast?)
Date: Wed, 17 Dec 2008 20:18:55 +0000
Message-ID: <200812172018.56230.tvrtko@ursulin.net>
References: <200812161939.30033.tvrtko@ursulin.net> <200812162012.29811.tvrtko@ursulin.net> <4948119B.5050000@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mk-outboundfilter-5-a-2.mail.uk.tiscali.com ([212.74.114.4]:10856
	"EHLO mk-outboundfilter-5-a-2.mail.uk.tiscali.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751700AbYLQUTB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 15:19:01 -0500
In-Reply-To: <4948119B.5050000@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 16 December 2008 20:37:47 Chris Snook wrote:

[snip]
> The real problem is that you get such lousy performance in unbonded gigabit
> mode.  Try oprofiling it to see where it's spending all that time.

Ha! Since I have put vanilla 2.6.27.9 on the server yesterday, but compiled it 
with distro configuration, I decided to try a minimal "optimised" config for 
this machine today.

With a reconfigured and recompiled kernel skge outbound performance went from 
13 Mb/s to 17 Mb/s so it seems there was something in there which was really 
hampering it.

Kernel configs are radically different so I am not sure if there is any point 
in sending them here? And I am also not sure if I will be able to spend any 
more time trying to pinpoint which config option was to blame. But if I will 
I will of course report my findings.

Tvrtko
