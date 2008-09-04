From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: Tree for September 3
Date: Thu, 4 Sep 2008 13:41:48 -0700
Message-ID: <20080904134148.0fde4508.akpm@linux-foundation.org>
References: <20080903191619.6b6b230e.sfr@canb.auug.org.au>
	<20080903214634.ea17ff53.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809032201510.3378@nehalem.linux-foundation.org>
	<20080903223318.84b6ce8b.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809040045190.3378@nehalem.linux-foundation.org>
	<20080904012544.cabed847.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809040143350.3452@nehalem.linux-foundation.org>
	<20080904015701.5959623a.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809040203510.3452@nehalem.linux-foundation.org>
	<20080904104554.32ffebea.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809041058140.3400@nehalem.linux-foundation.org>
	<20080904113408.d47c65f6.akpm@linux-foundation.org>
	<m163pb4pru.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	yhlu.kernel@gmail.com, ink@jurassic.park.msu.ru,
	jbarnes@virtuousgeek.org, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk, dwmw2@infradead.org, sam@ravnborg.org,
	johnstul@us.ibm.com, tglx@linutronix.de
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <m163pb4pru.fsf@frodo.ebiederm.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 04 Sep 2008 13:31:01 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> >> > config: http://userweb.kernel.org/~akpm/config-sony.txt
> >> > dmesg: http://userweb.kernel.org/~akpm/dmesg-sony-without.txt
> >> 
> >> That whole thing should just be a simple symlink:
> >> 
> >> 	fs/proc/proc_net.c:     proc_symlink("net", NULL, "self/net");
> >
> > /proc/self/net looks fine.
> >
> >> are you sure it's a plain tree of mine, without any of the patches 
> >> floating around between Eric/Al?
> >
> > yup, it's yesterday's mainline.
> 
> Does the problem happen if you disable selinux?
> 
> This feels like a case of selinux being over zealous.

yeah, adding `selinux=0' to the boot command line fixes it.
