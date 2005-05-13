From: Jeff Garzik <jgarzik@pobox.com>
Subject: git repository for net drivers available
Date: Thu, 12 May 2005 23:08:47 -0400
Message-ID: <42841A3F.7020909@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262222AbVEMDIz@vger.kernel.org>
To: Netdev <netdev@oss.sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Although I have over 200 net driver patches to go through in my 
'Pending' folder, I have fully converted the existing netdev-2.6 
repository from BitKeeper to git.  This includes the wireless-2.6 
repository.

rsync://rsync.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git

The main branch is fairly irrelevant, as you must choose the branch you 
wish:
> [jgarzik@pretzel netdev-2.6]$ ls .git/branches/
> 8139cp         e1000        ixgb     r8169            skge           we18
> 8139too-iomap  forcedeth    janitor  register-netdev  smc91x         wifi
> amd8111        ieee80211    orinoco  remove-drivers   smc91x-eeprom
> e100           iff-running  ppp      sis900           starfire


For folks looking for a consolidated netdev-2.6 repository (hi Andrew), 
that does not exist yet.  I will create an 'ALL' repository for this 
purpose, sometime soon.

	Jeff
