From: Steve Modica <modica@sgi.com>
Subject: Backporting 2.6 stack features
Date: Sat, 27 Sep 2003 08:36:16 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F759250.2040206@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi All,

Has anyone been working on backporting features of the 2.6 stack and 
tg3.c driver?

I've incoporated some small changes to the driver and mod_timer to 
reduce contention on some locks, but I'd also like to do the following:

1. get rid of do_cscum (which requires the newer sk_buff)
2. reduce contention in __wake_up
3. reduce contention in skb_release_data

Steve
