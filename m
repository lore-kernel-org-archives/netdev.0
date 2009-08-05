From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH]bluetooth: rfcomm_init bug fix
Date: Wed, 05 Aug 2009 08:35:55 -0700
Message-ID: <1249486555.3094.38.camel@localhost.localdomain>
References: <20090803.132924.151782729.davem@davemloft.net>
	 <1249343666.3094.12.camel@localhost.localdomain>
	 <20090803.191916.75688176.davem@davemloft.net>
	 <20090803.211136.00343745.davem@davemloft.net>
	 <1249405306.3094.18.camel@localhost.localdomain>
	 <a8e1da0908042216u16037395k96cce0746baa504e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org,
	alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <a8e1da0908042216u16037395k96cce0746baa504e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> >> >> do you mind at least waiting for an ACK from my side. I haven't even
> >> >> looked at the final patch.
> >> >
> >> > Sure, I haven't pushed it out yet, so now's your chance :)
> >>
> >> Grumble, I accidently pushed my net-2.6 queue out before you
> >> had a chance to reply, sorry :-(
> >
> > not a big deal. Just have to send a cleanup patch. The patch itself is
> > fine, but from a style perspective it is different than everything else
> > in the Bluetooth subsystem and I would have liked to fix that before
> > pushing it. I wait with that for 2.6.32 since it is not important.
> 
> Marcel, could you publish the bluetooth subsystem coding style
> somewhere? People including me are confused about it. I remembered I
> asked it from you, but it is still not very clear for me.

it is kernel coding style like everything else, but some variable naming
should be consistent. And that is nothing that is published, that is
something that has been done since Max wrote it. Check the rest of the
code.

> > The other Dave, please send patches to linux-bluetooth only and lets
> > follow the normal path to get them merged into Linus' tree. Skipping
> > bluetooth-2.6 is not an option. You have to use the same process than
> > everybody else.
> 
> Why linux-bluetooth only? IMHO there could be more people to comment
> and review  if I send patches to both lkml and subsystem mailing list.

Lets me make this perfectly clear here. Bluetooth patches are sent to
the linux-bluetooth mailing list. There is no need to send them to
netdev and/or LKML at the same time. Stop this cross-posting. They don't
get more review there anyway. I take care of sending them for net-2.6
inclusion if I feel that they are appropriate.

Regards

Marcel
