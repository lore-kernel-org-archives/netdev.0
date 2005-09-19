From: Dan Aloni <da-x@monatomic.org>
Subject: Re: workaround large MTU and N-order allocation failures
Date: Mon, 19 Sep 2005 10:13:58 +0300
Message-ID: <20050919071358.GA7107@localdomain>
References: <20050918143526.GA24181@localdomain> <20050918230822.GA5440@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932346AbVISHKp@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20050918230822.GA5440@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 19, 2005 at 01:08:22AM +0200, Francois Romieu wrote:
> Dan Aloni <da-x@monatomic.org> :
> [...]
> > The problem with large MTU is external memory fragmentation in
> > the buddy system following high workload, causing alloc_skb() to 
> > fail.
> 
> If the issue hits the Rx path, it is probably the responsibility of
> the device driver. Which kind of hardware do you use ?

We are using a SuperMicro board and the network driver is e1000. The
revision of the chipset is 82546GB-copper (maps to e1000_82546_rev_3).

This particular chipset does not support packet splitting, so we
are looking for a hack on the skb layer.

-- 
Dan Aloni
da-x@monatomic.org, da-x@colinux.org, da-x@gmx.net
