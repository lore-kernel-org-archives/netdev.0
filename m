From: Jerone Young <jerone@gmail.com>
Subject: Re: via-velocity heads up (was (Re: Linux 2.6.9-rc4 - pls test (and no more patches))
Date: Mon, 11 Oct 2004 11:53:09 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <9f50a7a0041011095324253e7f@mail.gmail.com>
References: <Pine.LNX.4.58.0410102016180.3897@ppc970.osdl.org>
	 <20041011072307.GA18577@electric-eye.fr.zoreil.com>
Reply-To: Jerone Young <jerone@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041011072307.GA18577@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Yes, I also am able to finally use the via-velocity card without it
taking down my router! The patches resolve issues with the card.  I
have been heavily using it now without a problem on X86_64 Linux.  I
have an Abit A8V with integrated Via Velocity card


On Mon, 11 Oct 2004 09:23:07 +0200, Francois Romieu
<romieu@fr.zoreil.com> wrote:
> Linus Torvalds <torvalds@osdl.org> :
> [...]
> > Summary of changes from v2.6.9-rc3 to v2.6.9-rc4
> > ============================================
> [...]
> > Fran?ois Romieu:
> >   o via-velocity: properly manage the count of adapters
> >   o via-velocity: removal of unused velocity_info.xmit_lock
> >   o via-velocity: velocity_give_rx_desc() removal
> >   o via-velocity: received ring wrong index and missing barriers
> >   o via-velocity: early invocation of init_cam_filter()
> >   o via-velocity: removal of incomplete endianness handling
> >   o via-velocity: wrong buffer offset in velocity_init_td_ring()
> >   o via-velocity: comment fixes
> 
> The attribution is a bit misleading as Tejun Heo <tj@home-tj.org>
> did the real work (he appears in the logs though).
> 
> People should really, really, test this code if they have been
> experiencing issues with the driver lately.
> 
> Test reports welcome here or on netdev@oss.sgi.com.
> 
> --
> Ueimor
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
