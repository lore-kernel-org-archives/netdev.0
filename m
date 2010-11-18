From: Nikola Ciprich <extmaillist@linuxbox.cz>
Subject: Re: 2.6.37-rc2 after KVM shutdown - unregister_netdevice: waiting
	for vmtst01eth0 to become free. Usage count = 1
Date: Thu, 18 Nov 2010 07:28:22 +0100
Message-ID: <20101118062822.GB3781@pcnci.linuxbox.cz>
References: <20101116084148.GA3781@pcnci.linuxbox.cz> <1289900812.5372.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: KVM list <kvm@vger.kernel.org>,
	netdev list <netdev@vger.kernel.org>,
	nikola.ciprich@linuxbox.cz,
	Linux kernel list <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1289900812.5372.1.camel@edumazet-laptop>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Yep, this is a known problem, thanks !
> 
> fix is there : 
> 
> http://patchwork.ozlabs.org/patch/71354/
Thanks Eric, this indeed fixes the problem..
I noticed the fix didn't make it to 2.6.37-rc2-git3 though,
maybe it just got omited?
anyways, thanks for help!
n.



> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
-------------------------------------
Ing. Nikola CIPRICH
LinuxBox.cz, s.r.o.
28. rijna 168, 709 01 Ostrava

tel.:   +420 596 603 142
fax:    +420 596 621 273
mobil:  +420 777 093 799
www.linuxbox.cz

mobil servis: +420 737 238 656
email servis: servis@linuxbox.cz
-------------------------------------
