From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: raw ipv6 broken in 2.4.19
Date: 13 Aug 2002 15:47:15 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <1029246435.1135.22.camel@tux>
References: <200208131330.RAA20947@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200208131330.RAA20947@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Tue, 2002-08-13 at 15:30, kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> > I've heard something about a PCI posting bug in the tulip hardware?
> > could this have anything to do with that?
> 
> No ideas. Eventually I moved that card to an ancient Neptunand it works
> flawlessly there.

I'm going to test it with a shitty i820 chipset later. Asus P3C-D and
the D-Link DFE570-TX is a really bad combination (thats why I don't use
that board anymore :), having ~90% cpu idle while maxing at ~75Mbit/s
routed is not fun. One NIC active at once is ok, but two or more just
destroys performance. But I've never had that problem with 440BX
chipsets.
 
> > I've attached a small dump. captured while trying to ping an OpenBSD
> 
> It looks boringly correct, indeed. Was it really taken at faulting machine?

Yes it was.

If the packets recieved is really corrupted wouldn't something have
complained before that patch was merged in 2.4.19-pre8 ?
if the ipv6 header was corrupt it would have been dropped?
if the icmp packet was corrupt, wouldn't ping6 have complained?

But then on the other side, it works fine with other NIC's...
And the machine answers icmp echo-requests without any problems with the
tulip. Nothing's beeing discarded then.

I think I'll just go with reverting that patch for now.

-- 
/Martin

Never argue with an idiot. They drag you down to their level, then beat
you with experience.
