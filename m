From: Lewis Adam-CAL022 <Adam.Lewis@motorola.com>
Subject: Processor off in La-La land
Date: Thu, 9 Sep 2004 13:07:01 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <FD52892BD296D71183B400065BFCB6900EDB4734@il02exm12>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi all,

I am writing a WLAN driver and every now and then Linux hangs (no oops).  I hooked up a jtag device in an effort to determine where the code was getting deadlocked.  However what I saw was that the CPU was not even looking at my code (or any Linux code for that matter) but was somewhere off in the weeds.  

Can somebody shed some light on what type of condition could cause such a a corruption of the stack?  The only one I can think of is doing a memcpy beyond the bounds of an array allocated on the stack, but to the best of my debugging I cannot find a case where that would happen.

Thanks!
Adam
