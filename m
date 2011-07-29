From: Alan Ott <alan@signal11.us>
Subject: Re: IP over 802.2 with LLC/SNAP
Date: Fri, 29 Jul 2011 14:42:46 -0400
Message-ID: <4E32FF26.7010701@signal11.us>
References: <4E2F8B7B.80906@signal11.us> <20110727133209.0d9dd6c4@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110727133209.0d9dd6c4@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/27/2011 08:32 AM, Alan Cox wrote:
>> So the question is, does Linux support IP over 802.2 with LLC/SNAP? 
> 
> It should be a 'simple matter of hacking' and there are example devices
> that fiddle with packets and add headers etc you can nick a lot of code
> from.

That sounds like it could be a fun project actually. It looks like I can
use what net/ipx does as a pattern, at least to get the receive going.
The send sounds a bit trickier but doable. I'll take a look when I get
some time (but it'll be a couple weeks at least).

> I figure if you can write an IP stack for an ancient Gould system
> you can probably do that.

I haven't written a fully-featured IP stack on the Gould, but it does
handle sending/receiving of UDP, which is what I need for my purposes.

> 
> The other way is to use the Linux raw packet interfaces, open a raw
> socket, push a BPF filter onto it to just get the frames for IP/SNAP and
> ARP/SNAP then modify them and feed them to the kernel tun/tap interface.
> 

Since I just needed to read the one packet on the Linux side, I ended up
just using libpcap to grab the raw packets and parse out the header for
now to get it working.

Thanks for the response and information,

Alan.
