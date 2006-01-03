From: Graham Gower <graham.gower@gmail.com>
Subject: Re: [PATCH] [TRIVIAL] prism54/islpci_eth.c: dev_kfree_skb in irq context
Date: Tue, 3 Jan 2006 22:49:33 +1030
Message-ID: <6ec4247d0601030419w377fd396x@mail.gmail.com>
References: <6.1.1.1.2.20060103105620.02c523e0@192.168.6.12>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751387AbWACMTf@vger.kernel.org>
To: Roger While <simrw@sim-basis.de>
In-Reply-To: <6.1.1.1.2.20060103105620.02c523e0@192.168.6.12>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

012345678901234567890123456789012345678901234567890123456789

On 03/01/06, Roger While <simrw@sim-basis.de> wrote:
> What makes you think this is in IRQ context ?
>

Er... yeah. I must have been off my nut when I wrote that comment.
A more apt comment should perhaps have been "dev_kfree_skb shouldn't be
used with interrupts disabled". Forgive my noobness, I'm a kernel patch virgin.

My logs were starting to fill with messages exatcly like that mentioned here:
http://patchwork.netfilter.org/netfilter-devel/patch.pl?id=2840

In any event, the patch at the end of that link was never applied (it doesn't
fix the other call to dev_kfree_skb). After applying my patch, I've not had any
more messages in the logs.

Graham
