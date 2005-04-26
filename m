From: Nicolas DICHTEL <nicolas.dichtel@6wind.com>
Subject: Question about QOS
Date: Tue, 26 Apr 2005 11:16:33 +0200
Message-ID: <426E06F1.9000105@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I set CONFIG_NET_SCH_CLK_GETTIMEOFDAY in my kernel. The macro 
PSCHED_TDIFF_SAFE calculates
the difference between two timestamps and uses the function 
psched_tod_diff() to do this.
If the clock is readjusted (due to ntp for example), this function can 
return a negative number
(if bound > 1000000) and then the flow is blocked by the kernel. Am I 
right ? or I miss
something ? Is this a bug ?


Thanks
Nicolas

