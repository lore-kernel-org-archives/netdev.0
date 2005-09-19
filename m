From: Al Boldi <a1426z@gawab.com>
Subject: Re: workaround large MTU and N-order allocation failures
Date: Mon, 19 Sep 2005 16:38:15 +0300
Message-ID: <200509191638.15506.a1426z@gawab.com>
References: <20050918143526.GA24181@localdomain> <1127111462.5272.7.camel@npiggin-nld.site>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932412AbVISNoF@vger.kernel.org>
To: netdev@vger.kernel.org
In-Reply-To: <1127111462.5272.7.camel@npiggin-nld.site>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nick Piggin wrote:
> On Sun, 2005-09-18 at 17:35 +0300, Dan Aloni wrote:
> > Hello,
> >
> > Is there currently a workaround available for handling large MTU
> > (larger than 1 page, even 2-order) in the Linux network stack?
> >
> > The problem with large MTU is external memory fragmentation in
> > the buddy system following high workload, causing alloc_skb() to
> > fail.
> >
> > I'm interested in patches for both 2.4 and 2.6 kernels.
>
> Yes there is currently a workaround. That is to keep increasing
> /proc/sys/vm/min_free_kbytes until your allocation failures stop.

How do you do it in 2.4?

--
Al
