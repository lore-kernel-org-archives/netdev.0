From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: ipgre rss is broken since gro
Date: Sun, 9 Dec 2012 04:04:05 +0200
Message-ID: <1355018645.3113.0.camel@lb-tlvb-dmitry.il.broadcom.com>
References: <504C9EFCA2D0054393414C9CB605C37F1BFB80B2@SJEXCHMB06.corp.ad.broadcom.com>
 <504C9EFCA2D0054393414C9CB605C37F1BFB80D8@SJEXCHMB06.corp.ad.broadcom.com>
 <CANn89iKE2RxRBWRuXGwjydQKjPLhPbcoZaJS5rcBKbJWWnL4ZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric Dumazet" <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2104 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030350Ab2LICD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Dec 2012 21:03:57 -0500
In-Reply-To: <CANn89iKE2RxRBWRuXGwjydQKjPLhPbcoZaJS5rcBKbJWWnL4ZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-12-08 at 18:01 -0800, Eric Dumazet wrote:
> On Sat, Dec 8, 2012 at 3:31 PM, Dmitry Kravkov <dmitry@broadcom.com> wrote:
> > Here is the trace for a while:
> >
> > BUG: unable to handle kernel NULL pointer dereference at           (null)
> > IP: [<ffffffff8144f35e>] skb_gro_receive+0xbe/0x5a0
> 
> Hi Dmitry
> 
> NULL pointer deref probably fixed on net tree (or Linus tree) by
> 
> http://git.kernel.org/?p=linux/kernel/git/davem/net.git;a=commit;h=c3c7c254b2e8cd99b0adf288c2a1bddacd7ba255
> 
> For the GRO stuff and RSS, I wonder if skbs have a property that makes
> them dropped somewhere, you might try drop_monitor / drop_watch
> 

I will try both and update ... 
Thanks
