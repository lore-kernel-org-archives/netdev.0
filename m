From: Ben Greear <greearb@candelatech.com>
Subject: Netdevice reference leak in af_ax25.c ??
Date: Thu, 01 Sep 2005 11:41:43 -0700
Message-ID: <43174B67.9030109@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: linux-hams@vger.kernel.org, ralf@linux-mips.org
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I believe the SO_BINDTODEVICE case in net/ax25/af_x25.c  (line 613 or so)
leaks a reference to a net device.  It does a dev_get_by_name,
which holds a reference, but since it never assigns the pointer
anywhere, I do not see how it can ever free it later.

Please clue me in as to where it's released if it actually is.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

