From: Adrian Bunk <bunk@stusta.de>
Subject: drivers/net/netxen/netxen_nic_hw.c: stack usage problem
Date: Wed, 13 Dec 2006 14:05:26 +0100
Message-ID: <20061213130526.GC3851@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964932AbWLMNFT@vger.kernel.org>
To: amitkale@netxen.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

<--  snip  -->

...
void netxen_nic_flash_print(struct netxen_adapter *adapter)
{
...
        struct netxen_new_user_info user_info;
...

<--  snip  -->


This allocates 2108 bytes on the stack.

That's too much considering that the complete stack might be only 4 kB.


cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
