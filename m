From: Daniel Drake <dsd@gentoo.org>
Subject: Re: Very strange Marvell/Yukon Gigabit NIC networking problems
Date: Tue, 30 Aug 2005 14:31:33 +0100
Message-ID: <43145FB5.6080300@gentoo.org>
References: <20050830122937.79855.qmail@web53605.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steve Kieu <haiquy@yahoo.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751434AbVH3Nbf@vger.kernel.org>
To: shemminger@osdl.org
In-Reply-To: <20050830122937.79855.qmail@web53605.mail.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Forwarding on, please reply-to-all in future.

Steve Kieu wrote:
> Hi all,
> 
> I have "fixed" the problem in a very wierd way.Reading
> your post I thought maybe when removing the driver
> itself it set some bit incorrectly. Then I decided to
> do:
> 
> Boot with init=/bin/bash  so bypass all other things.
> modprobe skge
> 
> run ifconfig eth0 ip_num  up
> 
> 
> ping  a host
> 
> then while pinging hit Ctrl+Alt+Del key to hot reboot
> the system.
> 
> I still see the light at the hub lits. Now I boot to
> winXP and as I expected , it worked!
> 
> No I boot 2.6.11 and it worked, so the problem resolve
> but I am tooooo scared to run 2613 now :-)
> 
> Hope this information helps debuging the driver.
> 
> Thanks.
> 
> S.KIEU
