From: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Subject: Re: workaround large MTU and N-order allocation failures
Date: Mon, 19 Sep 2005 10:25:29 -0700
Message-ID: <5fc59ff305091910252447d363@mail.gmail.com>
References: <20050918143526.GA24181@localdomain>
	 <20050918230822.GA5440@electric-eye.fr.zoreil.com>
	 <20050919071358.GA7107@localdomain>
Reply-To: ganesh.venkatesan@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Kernel List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932514AbVISRZd@vger.kernel.org>
To: Dan Aloni <da-x@monatomic.org>
In-Reply-To: <20050919071358.GA7107@localdomain>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

82546GB supports an incoming Rx packet to be received in multiple rx
buffers. A driver that enables this feature is under test currently.
What version of the e1000 are you using?

ganesh.

On 9/19/05, Dan Aloni <da-x@monatomic.org> wrote:
> On Mon, Sep 19, 2005 at 01:08:22AM +0200, Francois Romieu wrote:
> > Dan Aloni <da-x@monatomic.org> :
> > [...]
> > > The problem with large MTU is external memory fragmentation in
> > > the buddy system following high workload, causing alloc_skb() to
> > > fail.
> >
> > If the issue hits the Rx path, it is probably the responsibility of
> > the device driver. Which kind of hardware do you use ?
> 
> We are using a SuperMicro board and the network driver is e1000. The
> revision of the chipset is 82546GB-copper (maps to e1000_82546_rev_3).
> 
> This particular chipset does not support packet splitting, so we
> are looking for a hack on the skb layer.
> 
> --
> Dan Aloni
> da-x@monatomic.org, da-x@colinux.org, da-x@gmx.net
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
