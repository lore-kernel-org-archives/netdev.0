From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance tests
Date: Tue, 17 Jun 2003 22:12:14 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <16111.30238.978982.656557@robur.slu.se>
References: <20030616234937.GE18484@netnation.com>
	<20030617.085921.28790392.davem@redhat.com>
	<16111.18107.699689.704597@robur.slu.se>
	<20030617.095028.35014188.davem@redhat.com>
	<16111.20469.376899.55240@robur.slu.se>
	<Pine.LNX.4.56.0306171459230.6807@filesrv1.baby-dragons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com,
	Linux networking maillist <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: "Mr. James W. Laferriere" <babydr@baby-dragons.com>
In-Reply-To: <Pine.LNX.4.56.0306171459230.6807@filesrv1.baby-dragons.com>
List-Id: netdev.vger.kernel.org


Mr. James W. Laferriere writes:
 > 
 > 	Is 'fibstat' only for 2.5.x kernels ? 

 Yes.

 > 	The reason for that ? is there isn't a /proc/net/fib_stat .
 > 	Under 2.4.21 , which has no mention of fib_stat anywhere in the
 > 	sources .

 The kernel part creates /proc/net/fib_stat. I should pretty straight
 for 2.4.X too. If people find it useful it can be backported. Try. Look 
 at route.c and rt_cache_stat if you run into problems.

 > 	The next ? is packet-generator.c (appears) to require kernel
 > 	include files .  Is there an updated user level net/ includes ?

 It's a kernel module and should be compiled with the kernel.

 Cheers.
						--ro
