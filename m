From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: Very strange Marvell/Yukon Gigabit NIC networking problems
Date: Tue, 30 Aug 2005 13:18:57 -0700
Message-ID: <4807377b05083013185767744a@mail.gmail.com>
References: <20050830122937.79855.qmail@web53605.mail.yahoo.com>
	 <43145FB5.6080300@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: shemminger@osdl.org, Steve Kieu <haiquy@yahoo.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932435AbVH3US7@vger.kernel.org>
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <43145FB5.6080300@gentoo.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

on 2.6.11/12 when it isn't working maybe you should send us the output
of lspci -vvv

just a hint, I'm guessing its power management related, and / or
something to do with the pci bus code.

On 8/30/05, Daniel Drake <dsd@gentoo.org> wrote:
> Forwarding on, please reply-to-all in future.
> 
> Steve Kieu wrote:
> > Hi all,
> >
> > I have "fixed" the problem in a very wierd way.Reading
> > your post I thought maybe when removing the driver
> > itself it set some bit incorrectly. Then I decided to
> > do:
> >
> > Boot with init=/bin/bash  so bypass all other things.
> > modprobe skge
> >
> > run ifconfig eth0 ip_num  up
> >
> >
> > ping  a host
> >
> > then while pinging hit Ctrl+Alt+Del key to hot reboot
> > the system.
> >
> > I still see the light at the hub lits. Now I boot to
> > winXP and as I expected , it worked!
> >
> > No I boot 2.6.11 and it worked, so the problem resolve
> > but I am tooooo scared to run 2613 now :-)
> >
> > Hope this information helps debuging the driver.
> >
> > Thanks.
> >
> > S.KIEU
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
