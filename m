From: "Chris Carpinello" <chriscarpinello@hotmail.com>
Subject: e1000 w/ NAPI + SMP = 99% CPU utilization
Date: Mon, 07 Jun 2004 15:08:40 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BAY1-F101MkaFmV8ih90004a5a7@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

With a stock 2.6.5 kernel, I'm building the e1000 driver as a module
w/ NAPI turned on for an SMP host (Dell PowerEdge 1650 with 4 1Gb
Intel NICs).  ksoftirqd/0 is using 99% CPU utilization.  However, when
I recompile the kernel with NAPI turned off, ksoftirqd/0 behaves
normally.  Likewise, when I leave NAPI configured but turn off SMP
support, ksoftirqd is fine.  The system in question has 2x Intel
Corp. 82544EI (rev 02) and 2x Intel Corp. 82543GC (rev 02).

I'm willing to test patches.  Please CC me on responses, as I'm not
subscribed.  Thanks.

- Chris
