From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [openib-general] Re: LLTX and netif_stop_queue
Date: Wed, 19 Jan 2005 16:46:14 -0800
Message-ID: <20050119164614.6f74daf3@dxpl.pdx.osdl.net>
References: <5cac192f0412230110628749e3@mail.gmail.com>
	<41CAF444.3000305@trash.net>
	<5cac192f04122408102129af43@mail.gmail.com>
	<1104240717.1100.66.camel@jzny.localdomain>
	<5cac192f0501021530672a908a@mail.gmail.com>
	<1104764660.1048.578.camel@jzny.localdomain>
	<52brc68q05.fsf@topspin.com>
	<5cac192f05010308414a25b548@mail.gmail.com>
	<527jmu8nbw.fsf@topspin.com>
	<5cac192f0501030907c755135@mail.gmail.com>
	<20050103171227.GD7370@esmail.cup.hp.com>
	<1104812294.1085.53.camel@jzny.localdomain>
	<20050119144711.3fdd3d93.davem@davemloft.net>
	<20050119151853.259de49a@dxpl.pdx.osdl.net>
	<20050119154132.68f0bb4f.davem@davemloft.net>
	<41EEF52C.8000905@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, hadi@cyberus.ca, iod00d@hp.com,
        eric.lemoine@gmail.com, roland@topspin.com, netdev@oss.sgi.com,
        ak@suse.de, openib-general@openib.org, kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <41EEF52C.8000905@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 19 Jan 2005 19:02:52 -0500
Jeff Garzik <jgarzik@pobox.com> wrote:

> David S. Miller wrote:
> > Usually we strive for BH disabling locks in order to decrease the
> > amount of hard IRQ disabling time in the kernel.  But here, as soon
> > as we call into ->hard_start_xmit(), the driver typically turns hard
> > IRQs off anyways.
> [...]
> > Also, changing dev->xmit_lock to be IRQ disabling is not %100 trivial.
> 
> 
> Agreed on both counts...

But in the end it would be safer than the current LLTX usage in drivers
which seems like it opening up problems.


-- 
Stephen Hemminger	<shemminger@osdl.org>
