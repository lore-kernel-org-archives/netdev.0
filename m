From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Mon, 29 Jun 2009 10:58:20 +0000
Message-ID: <20090629105820.GD4712@ff.dom.local>
References: <20090629083315.GA4712@ff.dom.local> <4A488EB8.4070602@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <robert@robur.slu.se>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:59430 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350AbZF2K6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 06:58:24 -0400
Received: by bwz9 with SMTP id 9so3167483bwz.37
        for <netdev@vger.kernel.org>; Mon, 29 Jun 2009 03:58:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A488EB8.4070602@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 29, 2009 at 11:51:52AM +0200, Pawe=B3 Staszewski wrote:
> I apply this patch
>
> fib_triestats in attached file :)
>
>> ------------------->
>> ipv4: Fix fib_trie rebalancing, part 3
>>
>> Alas current delaying of freeing old tnodes by RCU in trie_rebalance
>> is still not enough because we can free a top tnode before updating =
a
>> t->trie pointer.
>>
>> Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
>> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>> ---

David, I guess you could add:

Tested-by: Pawel Staszewski <pstaszewski@itcare.pl>

Thanks,
Jarek P.
