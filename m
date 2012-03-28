From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 5/5] r8169: support RTL8411
Date: Wed, 28 Mar 2012 10:52:24 +0800
Message-ID: <97E69EF42D4742BA8789F8EAAA3A4AF8@realtek.com.tw>
References: <1332834834-5185-1-git-send-email-hayeswang@realtek.com> <1332834834-5185-5-git-send-email-hayeswang@realtek.com> <20120327225453.GD22177@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120327225453.GD22177@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> > @@ -250,6 +252,9 @@ static const struct {
> >  							
> JUMBO_9K, false),
> >  	[RTL_GIGA_MAC_VER_37] =
> >  		_R("RTL8402",		RTL_TD_1, FIRMWARE_8402_1,
> > +							JUMBO_1K, true),
> > +	[RTL_GIGA_MAC_VER_38] =
> > +		_R("RTL8411",		RTL_TD_1, FIRMWARE_8411_1,
> >  							JUMBO_1K, true)
> 
> Realtek's product page documents this chipset as a gigabit 
> one. It seems
> strange to configure it as a jumbo packet unable one.
> 

It is my mistake. I would fix it.

[...]
> "The RTL8411 supports Receive Side Scaling (RSS) to hash incoming TCP
> connections and load-balance received data processing across 
> multiple CPUs.
> RSS improves the number of transactions per second and number 
> of connections
> per second, for increased network throughput. Header Data 
> Split (HDS) support
> enables faster processing of TCP/IP networking protocols for 
> improved network
> performance.
> 
> Virtual Machine Queue (VMQ) is a hardware virtualization 
> technology for the
> efficient transfer of network traffic to a virtualized host 
> OS. VMQ uses
> hardware packets filtering to deliver packet data from an 
> external virtual
> machine network directly to virtual machines, which reduces 
> the overhead of
> routing packets and copying them from the management 
> operating system to the
> virtual machine.
> 
> Note: RTL8411 Virtual Machine Queue (VMQ) is only functional 
> in computers
> running Windows Server 2008 R2 with the Hyper-V server role 
> installed."
> 
> Will Realtek consider helping make those being available on Linux ?
> 

I don't have the documents about these. I need more information from the other
engineers, and I have to discuss with my leader. Maybe I could research the
possibility when I have more time.
 
Best Regards,
Hayes
