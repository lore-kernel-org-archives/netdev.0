From: mcgrof@studorgs.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Tue, 31 Aug 2004 17:37:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040831213719.GH31207@ruslug.rutgers.edu>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <4134C1A7.50600@pobox.com> <200408312214.44701.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>,
        Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
        Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        Jouni Malinen <jkmaline@cc.hut.fi>, acx100-devel@lists.sourceforge.net,
        prism54-devel@prism54.org, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
Content-Disposition: inline
In-Reply-To: <200408312214.44701.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Aug 31, 2004 at 10:14:38PM +0300, Vladimir Kondratiev wrote:
> On Tuesday 31 August 2004 21:21, Jeff Garzik wrote:
> JG> Denis Vlasenko wrote:
> JG> > I think 'senior' network guys are in position to decide upon which
> JG> > of currently available 802.11 stacks we should continue to work.
> JG> > (Atheros has one, said to be derived from BSD, is there any others?)
> JG>
> JG>
> JG> Already have.  Start with the code in wireless-2.6 -- HostAP -- and use
> JG> DaveM's 802.11 stack template as a model for actually integrating 802.11
> JG> very tightly with the rest of the net stack.
> JG>
> JG>
>  http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/davem-p8
> 0211.tar.bz2 JG>
> JG>  Jeff
> 
> This stack raises many questions.
> 
> The very idea to implement generic softmac is pretty good.
> 
> So, first questions:
> 
> - it defines structures that was present in Jean's wireless extensions. So, 
> will it replace Jean's wireless extensions, merge with it, or some other 
> relationship? Partually, I don't like to see definitions for .11 header and 
> field constants in 2 includes.
> 
> - QoS stuff is not defined. I suppose recent cards will all support WME and/or 
> TGe. It is easy to add "QoS control" field to header and new frame types, but 
> it is harder to formally define how PHY should handle it. And, TGe is big 
> story on itself, with all its HCCA, block ack, etc. I also think that QoS, as 
> it is defined in TGe, required driver to have several tx queues and 
> start/stop them separately. Is anyone working on it? I'll be glad to join.
> 
> - Security is not up-to date either. We need .1x, EAS, TKIP etc. This need to 
> be done for modern cards to use this infrastructure.

This is handled by hostap wpa_supplicant now, which is going to be part
of WE18. The question I think is whether somoene plans on re-doing it on
wireless-2.6, since as you mentioned it seems WE are being redone on
davem's patch.

	Luis

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
