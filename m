From: Gabe Black <gabebblack@gmail.com>
Subject: unres_qlen and arp resolution/cache behavior
Date: Tue, 25 Oct 2011 16:12:30 -0600
Message-ID: <CAHUoWVk-AWekfmXrbY8PeZ2c9nzm6jyuE=orzd7Mxb8HiDuepQ@mail.gmail.com>
Reply-To: gabebblack@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Documentation about net.ipv4.neigh.*.unres_qlen seems to indicate that
it determines the number of frames that will be held while an arp is
being resolved.

Say packets start transmitting at a destination that needs to be (arp)
resolved.  If the number of backlogged packets exceeds the queue
length, then the frames are dropped (from what I understand).  My
question is what if the arp cached address expires and another arp is
issued.  Does the same scenario occur (i.e. packets are backlogged
until that arp returns)?  Or is the kernel smart enough to use the old
cached value until the arp returns, at which point it then uses the
updated address?

Thank you for your time,
Gabe
