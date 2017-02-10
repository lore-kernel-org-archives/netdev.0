From: Marty Plummer <netz.kernel@gmail.com>
Subject: (unknown)
Date: Fri, 10 Feb 2017 01:41:19 -0600
Message-ID: <20170210074118.vchxsn7fag6tlsmg@tha-monstah.mydomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greetings.

I think I may have found a bug with the hix5hd2_gmac driver; unless I'm
missing something, it appears that somehow the net_device struct is not
being initialized properly in the hix5hd2_dev_probe function.

Having set up my devicetree properly (I hope, still new to this), I first
recieved an error when inserting the module:
"(unnamed net_device) (uninitialized): No irq resource"
while I very clearly have the interrupts property defined within this node.

Removing the phy-handle node for testing purposes, I get a similar message:
"(unnamed net_device) (uninitialized): not find phy-handle"

So, it seams to my (admittedly inexperienced) mind that the ndev pointer is
not being initialized properly, or that the error checking at line 1111
is not functioning properly either, for it to have gotten so far along
into the function, only to fail at the attempt to access the ndev pointer.

If you require more information from me, please let me know.

Marty
