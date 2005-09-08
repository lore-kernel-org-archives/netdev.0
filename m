From: Jens Axboe <axboe@suse.de>
Subject: Re: 2.6.13-git7 strange system freeze
Date: Thu, 8 Sep 2005 17:46:23 +0200
Message-ID: <20050908154620.GB6097@suse.de>
References: <6bffcb0e050908051412e945c9@mail.gmail.com> <6bffcb0e050908083822616326@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	akpm@osdl.org, "David S. Miller" <davem@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932699AbVIHPqi@vger.kernel.org>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Content-Disposition: inline
In-Reply-To: <6bffcb0e050908083822616326@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 08 2005, Michal Piotrowski wrote:
> Hi,
> 
> kernel: 2.6.13-mm2
> 
> it happens when I try to download new gnome-2.12 livecd from bittorrent.
> 
> ng02:/home/michal# tail /var/log/kern.log
> [..]
> Sep  8 17:15:39 ng02 kernel: [ 3241.479108] KERNEL: assertion
> ((int)tp->lost_out >= 0) failed at net/ipv4/tcp_input.c (2148)
> Sep  8 17:15:39 ng02 kernel: [ 3241.479192] KERNEL: assertion
> ((int)tp->lost_out >= 0) failed at net/ipv4/tcp_input.c (1127)
> Sep  8 17:15:39 ng02 kernel: [ 3241.479736] KERNEL: assertion
> ((int)tp->lost_out >= 0) failed at net/ipv4/tcp_input.c (1127)
> Sep  8 17:15:39 ng02 kernel: [ 3241.831114] KERNEL: assertion
> ((int)tp->lost_out >= 0) failed at net/ipv4/tcp_input.c (2148)
> Sep  8 17:15:40 ng02 kernel: [ 3242.103942] KERNEL: assertion
> ((int)tp->lost_out >= 0) failed at net/ipv4/tcp_input.c (2148)
> Sep  8 17:15:40 ng02 kernel: [ 3242.103951] Leak l=4294967295 3

Same thing happens in -git from this morning.

-- 
Jens Axboe
