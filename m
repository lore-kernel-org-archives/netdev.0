From: Christopher Chan <cchan@outblaze.com>
Subject: 2.6.4 e100 NAPI - dst cache overflow and network unavailability
Date: Fri, 09 Apr 2004 08:45:12 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4075F218.90804@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I previously sent email to the list about seeing dst cache overflows and 
the kernel spewing gibberish (at which point the box usually needs to be 
rebooted as you'd wait a long time for the kernel to recover) to serial 
console.

For all those cases with different values in route/max-size, 
route/gc_thresh and tcp_max_syn_backlog, I'd get the problems even under 
sufficient network load.

However, I had NAPI enabled in the e100 driver then.

Turning NAPI off for the e100 driver has meant that the box has now been 
up several days without any problems under heavy network load.

I have not tried out 2.6.5 with NAPI enabled but 2.6.5 without NAPI 
enabled is stable.
