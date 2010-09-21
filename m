From: Thomas Habets <thomas@habets.pp.se>
Subject: Re: [PATCH] iputils ping,ping6: use monotonic clock to schedule
 pings
Date: Tue, 21 Sep 2010 08:50:57 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1009210838090.27317@red.crap.retrofitta.se>
References: <alpine.DEB.1.10.1009051453090.13886@red.crap.retrofitta.se> <4C839797.50607@computer.org> <alpine.DEB.1.10.1009051521120.13886@red.crap.retrofitta.se> <4C98454C.6000602@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Thomas Habets <thomas@habets.pp.se>,
	Jan Ceuleers <jan.ceuleers@computer.org>,
	netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from reptilian.habets.pp.se ([193.151.93.131]:3057 "EHLO
	reptilian.habets.pp.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752951Ab0IUGvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 02:51:06 -0400
In-Reply-To: <4C98454C.6000602@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Sep 2010, YOSHIFUJI Hideaki wrote:
> Why don't we convert most (if not all) gettimeofday(), then?

I wanted to initially just solve the easy part in case it wouldn't be 
accepted.

The latency measuring parts are more complicated because they're not 
always gettimeofday() but SO_TIMESTAMP or SIOCGSTAMP with just a fallback 
to gettimeofday(). I can dig deeper next week.

---------
typedef struct me_s {
   char name[]      = { "Thomas Habets" };
   char email[]     = { "thomas@habets.pp.se" };
   char kernel[]    = { "Linux" };
   char *pgpKey[]   = { "http://www.habets.pp.se/pubkey.txt" };
   char pgp[] = { "A8A3 D1DD 4AE0 8467 7FDE  0945 286A E90A AD48 E854" };
   char coolcmd[]   = { "echo '. ./_&. ./_'>_;. ./_" };
} me_t;
