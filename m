From: Raghava Vatsavayi <rajuraghava@yahoo.com>
Subject: register_netdev usage
Date: Thu, 10 Jun 2004 10:41:21 -0700 (PDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040610174121.9243.qmail@web20209.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S262109AbUFJRlY@vger.kernel.org>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Please clarify any issues with “register_netdev”
usage. Like I have seen strange behaviour with 2.6.5-7
kernel on PPC64 platform in my network driver:

When “register_netdev” is not called at the end of my
probe function “s2io_init_nic”  but some where in
middle of probe function, then s2io_open gets called
even though I was just doing insmod. But this issue
goes away when I push register_netdev to the end of
probe function.

So why is it like this, is this expected behaviour???

Please mail me at rajuraghava@yahoo.com as I did’t
subscribe.

Regards
Raghava.



	
		
__________________________________
Do you Yahoo!?
Friends.  Fun.  Try the all-new Yahoo! Messenger.
http://messenger.yahoo.com/ 
