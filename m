From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: 2.6.13-git7 strange system freeze
Date: Thu, 8 Sep 2005 17:38:22 +0200
Message-ID: <6bffcb0e050908083822616326@mail.gmail.com>
References: <6bffcb0e050908051412e945c9@mail.gmail.com>
Reply-To: michal.k.k.piotrowski@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932706AbVIHPiZ@vger.kernel.org>
To: LKML <linux-kernel@vger.kernel.org>
In-Reply-To: <6bffcb0e050908051412e945c9@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

kernel: 2.6.13-mm2

it happens when I try to download new gnome-2.12 livecd from bittorrent.

ng02:/home/michal# tail /var/log/kern.log
[..]
Sep  8 17:15:39 ng02 kernel: [ 3241.479108] KERNEL: assertion
((int)tp->lost_out >= 0) failed at net/ipv4/tcp_input.c (2148)
Sep  8 17:15:39 ng02 kernel: [ 3241.479192] KERNEL: assertion
((int)tp->lost_out >= 0) failed at net/ipv4/tcp_input.c (1127)
Sep  8 17:15:39 ng02 kernel: [ 3241.479736] KERNEL: assertion
((int)tp->lost_out >= 0) failed at net/ipv4/tcp_input.c (1127)
Sep  8 17:15:39 ng02 kernel: [ 3241.831114] KERNEL: assertion
((int)tp->lost_out >= 0) failed at net/ipv4/tcp_input.c (2148)
Sep  8 17:15:40 ng02 kernel: [ 3242.103942] KERNEL: assertion
((int)tp->lost_out >= 0) failed at net/ipv4/tcp_input.c (2148)
Sep  8 17:15:40 ng02 kernel: [ 3242.103951] Leak l=4294967295 3

Regards,
Michal Piotrowski
