From: Horms <horms@verge.net.au>
Subject: Re: in-driver QoS
Date: Thu, 10 Jun 2004 11:45:37 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040610024536.GB17334@verge.net.au>
References: <20040608184831.GA18462@bougret.hpl.hp.com> <200406090851.40691.vkondra@mail.ru> <1086780010.1051.106.camel@jzny.localdomain> <200406092127.28477.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, Vladimir Kondratiev <vkondra@mail.ru>
Content-Disposition: inline
In-Reply-To: <200406092127.28477.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 09, 2004 at 09:27:28PM +0300, Vladimir Kondratiev wrote:
> >
> > Indeed.
> > Looking at the transmit path code it seems doable.
> > for each dev->id you also maintain a dev->id_state.
> > We either use skb->fwmark or skb->priority to map to the different
> BTW, what is fwmark? in 2.6.6 it is not present.

The name in the kernel was changed to nfmark a while ago. 
Though is seems to be still referenced as fwmark quite a lot
in documentation. I believe its primary use is for the mark target
and match in netfilter/iptables. 

-- 
Horms
