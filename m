From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Re: [PATCH] e1000 poll behavior
Date: Thu, 16 Dec 2004 13:02:06 +0100
Message-ID: <16833.31038.665676.278498@robur.slu.se>
References: <1103104917.41c00b9533464@www.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gandalf@wlug.westbo.se, robert.olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jchapman@katalix.com
In-Reply-To: <1103104917.41c00b9533464@www.katalix.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


jchapman@katalix.com writes:
 > Is there any advantage in exiting NAPI polled state as soon as
 > possible with the work_done < work_to_do test? Why not stay in
 > polled mode until no rx or tx work is done, i.e. only exit polled
 > state if work_done is zero? 

 Yes it's a variant.

 > When working on e100 a while ago, I found better and more consistent
 > pps numbers by staying in polled mode until the interface went idle.
 > See current e100 code. Unfortunately I don't have e1000 hardware to
 > test if the same is true for e1000.
 
 I'll try this with the forwarding setup when I got a chance but I'll 
 think server-like setups are more interesting to test.

						--ro
