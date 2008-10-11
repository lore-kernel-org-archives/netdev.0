From: Marcin Slusarz <marcin.slusarz@gmail.com>
Subject: Re: 2.6.27 seems to break something with DSL
Date: Sat, 11 Oct 2008 16:02:45 +0200
Message-ID: <20081011140240.GA5985@joi>
References: <c6740f810810110553q75478033ub984651d5509199b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Philip Stark <heller.barde@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757122AbYJKODZ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <c6740f810810110553q75478033ub984651d5509199b@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 11, 2008 at 02:53:16PM +0200, Philip Stark wrote:
> Hi,
> 
> I'm sorry, I didn't lurk before making my first posting to this list,
> but it seemed to me that this might be an important problem/bug (if it
> is one).
> 
> first off, my network infrastructure:
> 
> "internet" --(magic*)-- DSL Modem --(DHCP)-- Router --(DHCP)-- Computer
> * PPPsomething i guess...
> 
> My observations so far:
> 
> with kernel =< 2.6.26 i can connect to the rest of the world perfectly
> (ping works and i can browse "the internet")
> 
> now with kernel 2.6.27, i.e with all the release candidates and also
> with the final version from yesterday i can ping anything just fine,
> but i can't browse. that is when i 'wget kernel.org' it resolves the
> address into the correct IP and then goes on to 'connecting' just to
> grind to a complete halt. after some time of course it times out.
> it seems to  be related to the packet  size because ping only seems to
> work because it uses small packets. if i increase the ping size up to
> 1000 bytes, it fails as well. (while it does work on 2.6.26)
> 
> oh and it is the same problem on the wireless and the wired interface.
> on 2 different laptops and on my desktop (which have different
> networking chips, two intel and one realtek)
> 
> best Regards
> Philip Stark
> 
> PS: if i horribly misposted, please slap me across the face and ignore me :)

CC'ing netdev
