From: Rob Landley <rob@landley.net>
Subject: Re: [PATCH] sh_eth: fix TX buffer byte-swapping
Date: Sun, 13 Dec 2015 16:25:17 -0600
Message-ID: <CAOS_Y6ScbQg-Kh_gNTh2XWKyDEN_uGJt5q1Na5GFDWR9MSbabw@mail.gmail.com>
References: <4052048.4A561jYI0l@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4052048.4A561jYI0l@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 13, 2015 at 12:27 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> For the little-endian SH771x kernels the driver has to byte-swap the RX/TX
> buffers,  however yet unset physcial address from the TX descriptor is used
> to call sh_eth_soft_swap(). Use 'skb->data' instead...

Rummage rummage rummage...

Ah, my sh4 qemu system has an rtl-8139cp network driver, and the sh2
j-core numato board one is A) big endian, B) has an oddball version
with its own driver.

That's why I haven't hit this.

Rob
