From: Yuchung Cheng <ycheng@google.com>
Subject: Re: RACK not getting disabled
Date: Mon, 18 Sep 2017 15:05:22 -0700
Message-ID: <CAK6E8=e96F+fh+RNL33H9+0VTUH-HCe8fhV5Zh7Jdws9jXFxNg@mail.gmail.com>
References: <20170918201428.GB28186@strugglingcoder.info> <1505769494.29839.34.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170918212952.GC28186@strugglingcoder.info> <CAK6E8=eu+1ywBfpAM34seZDKVc-ep5HBuz9fQRuzoaX9BWqeJA@mail.gmail.com>
 <20170918215522.GE28186@strugglingcoder.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: hiren panchasara <hiren@strugglingcoder.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f177.google.com ([209.85.217.177]:51276 "EHLO
        mail-ua0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750813AbdIRWGE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 18:06:04 -0400
Received: by mail-ua0-f177.google.com with SMTP id 72so1159074uas.8
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:06:04 -0700 (PDT)
In-Reply-To: <20170918215522.GE28186@strugglingcoder.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 18, 2017 at 2:55 PM, hiren panchasara
<hiren@strugglingcoder.info> wrote:
> On 09/18/17 at 02:46P, Yuchung Cheng wrote:
>> On Mon, Sep 18, 2017 at 2:29 PM, hiren panchasara
>> <hiren@strugglingcoder.info> wrote:
>> > On 09/18/17 at 02:18P, Eric Dumazet wrote:
>> >> On Mon, 2017-09-18 at 13:14 -0700, hiren panchasara wrote:
>> >> > Hi all, I am trying to disable rack to see 3dupacks in action during
>> >> > loss-detection but based on the pcap, I see that it's still trigger
>> >> > loss-recovery on the first SACK (as if RACK is still enabled/active).
>> just to be clear: 3-dupack (aka RFC3517) is still enabled with RACK
>> enabled. I am experimenting a patch set to disable 3-dupack approach
>> completely.
>
> So any incoming packet undergoes both checks right now to decide whether
> to mark it lost based on 3-dupacks (and eventually rfc6675) and also
> rack? Any insights into how they are working together would be great.
>
> Also whichever scheme detects loss first can kick connection into
> loss-recovery, right?
Yes. essentially we run both algorithms. the recovery starts when any
packet is deemed lost

>
> Thanks for the clarification, Yuchung.
>
> Cheers,
> Hiren
