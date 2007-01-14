From: "evan foss" <evanfoss-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V2] bcm43xx: Fix failure to deliver PCI-E interrupts
Date: Sun, 14 Jan 2007 13:14:40 -0500
Message-ID: <4a55afb80701141014n6b0ad36bp70fd6b21d3200eae@mail.gmail.com>
References: <45a7ceb2.m02aaCgouBsadVk/%Larry.Finger@lwfinger.net>
	<9b3e2dc20701121050p52e13d92r1ec78e1881bbed3@mail.gmail.com>
	<45A7F501.9080202@docksud.com.ar>
	<4a55afb80701121459q4f23083t6f92a7e3bc85ccb1@mail.gmail.com>
	<4a55afb80701132228q2e264606mf8948a45507e59ea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
In-Reply-To: <4a55afb80701132228q2e264606mf8948a45507e59ea-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

I sent this to the list but I don't know if it got to the list.

On 1/14/07, evan foss <evanfoss-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Results so far....
> In a word Wow. It still doesn't work but I suspect that is could just
> be my configuration. Power levels are not being reported correctly all
> the time iwlist works but nothing else to my knowledge. I remember
> there being talk of power level reporting patches. Is there anything I
> can try adding. For the first time in a long time it does associate
> with AP's but I can't dhcpcd eth1. I am using an access point next
> door. Mine is down. I will test it with a good one at school on
> Tuesday.
>
> ####To recap I am on...
> MFG: Compaq V3000 (V3019US)
> CPU: AMD Turion 64 x2
> Kernel: linux-2.6.18-gentoo-r2
>         I have SMP on and I am in 64 bit.
> BCM Chip: BCM4311
> BCM FW: V3 Sorry I don't recall exactly what version
>
> ####Patches used
> patch_2.6.18.1_fix_leds
> patch_2.6.18.1_for_PCI-E
> radio_hwenable_for_2.6.18
>
> ####The following work
> ifconfig eth1 up
> iwconfig eth1 essid NAME channel #
> kismet -c bcm43xx,eth1,bcm43xx
> iwlist eth1 scan        <-the power levels are reported here
>
> ####The following don't work
> iwconfig                <-the power levels are reported as always being 0
> kismet                  <-no power levels are reported
> LED                     <-always off (I have a slider switch on the front to turn radio on/off)
> dhcpcd eth1             <-low transmit power???
>
> #####The following don't work but might be my fault (I will get back
> to you later on these)
> dhcpcd eth1
>
> #####example bad iwconfig power level reporting
> eth1      IEEE 802.11b/g  ESSID:"linksys"  Nickname:"Broadcom 4311"
>           Mode:Managed  Frequency=2.437 GHz  Access Point: 00:16:B6:43:DE:C4
>           Bit Rate=1 Mb/s   Tx-Power=18 dBm
>           RTS thr:off   Fragment thr:off
>           Encryption key:off
>           Link Quality=0/100  Signal level=-256 dBm  Noise level=-256 dBm
>           Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
>           Tx excessive retries:0  Invalid misc:0   Missed beacon:0
>
>
>
> --
> http://www.coe.neu.edu/~efoss/
> http://evanfoss.googlepages.com/
>


-- 
http://www.coe.neu.edu/~efoss/
http://evanfoss.googlepages.com/
