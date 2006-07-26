From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUGs in skb_checksum_help() and skb_gso_segment() in 2.6.18-rc2
Date: Wed, 26 Jul 2006 12:32:09 +1000
Message-ID: <E1G5ZBx-00084U-00@gondolin.me.apana.org.au>
References: <20060725152939.GA2246@2ka.mipt.ru>
Cc: zdzichu@irc.pl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35848 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030366AbWGZCcj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 22:32:39 -0400
To: johnpol@2ka.mipt.ru (Evgeniy Polyakov)
In-Reply-To: <20060725152939.GA2246@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> On Tue, Jul 25, 2006 at 05:15:04PM +0200, Tomasz Torcz (zdzichu@irc.pl) wrote:
>> BUG: warning at net/core/dev.c:1171/skb_checksum_help()
>>  [<c010374a>] show_trace_log_lvl+0x51/0xe6
>>  [<c01037e9>] show_trace+0xa/0xc
>>  [<c01038b4>] dump_stack+0x13/0x15
>>  [<c02b41c4>] skb_checksum_help+0x4d/0xeb
>>  [<c02f9cbe>] ip_nat_fn+0x47/0x19a
> 
> It is not a bug, but remind to update nat helper function.

Yes, I need to add CHECKSUM_COMPLETE vs. CHECKSUM_PARTIAL first so that
we actually know which is which in NAT.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
