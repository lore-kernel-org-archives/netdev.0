From: Horms <horms@verge.net.au>
Subject: Re: bridge between ppp and ethernet - 1 IP address and assign it to another host
Date: Wed, 16 Mar 2005 11:37:54 +0900
Message-ID: <20050316023752.GS23777@verge.net.au>
References: <20050305220429.GA9335@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: bert hubert <ahu@ds9a.nl>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050305220429.GA9335@outpost.ds9a.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Mar 05, 2005 at 11:04:30PM +0100, bert hubert wrote:
> Hi people,
> 
> I have an application that wants a Real IP Address, but for a variety of
> good reasons, I can't connect the machine to the internet directly.
> 
> So, I need this:
> 
> DSL - Linux - Windows PC
> 
> Where I need the Windows PC to think it has the real single IP addres
> assigned to me by the DSL provider. I run PPTP on the Linux box, which
> should not touch traffic for that IP address.
> 
> Now I know that several DSL routers are capable of this stunt, so we should
> be able to do this too. But how?
> 
> Linux is pretty stubborn in routing packets for its own IP address elsewhere
> (rightfully so). I previously spent some time on this with a lot of
> SNAT/DNAT trickery but it is not very pleasing, nor did it work.
> 
> What we're trying to do is a lot like building a bridge between ethernet and
> ppp, but not quite.
> 
> Anybody have ideas? If we find something I'll post it on http://lartc.org.

Have you tried using LVS with Direct Routing? It might do the trick
as long as the Windows PC can route outgoing packets directly through
the DLS router.

-- 
Horms
