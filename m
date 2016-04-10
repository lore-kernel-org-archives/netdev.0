From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH v2 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Sun, 10 Apr 2016 09:07:54 -0400
Message-ID: <570A502A.3050006@mojatatu.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
 <20160408123614.2a15a346@redhat.com> <20160408143340.10e5b1d0@redhat.com>
 <20160408172651.GA38264@ast-mbp.thefacebook.com>
 <20160408220808.682630d7@redhat.com>
 <20160408213414.GA43408@ast-mbp.thefacebook.com>
 <CALx6S36d74D-8Rx762nmNwb1TF0M0sBfojBhUF96prJiYmDYiQ@mail.gmail.com>
 <57091FCE.50104@mojatatu.com>
 <20160409172634.GA55330@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
 Jesper Dangaard Brouer <brouer@redhat.com>,
 Brenden Blanco <bblanco@plumgrid.com>, "David S. Miller"
 <davem@davemloft.net>,
 Linux Kernel Network Developers <netdev@vger.kernel.org>,
 Or Gerlitz <ogerlitz@mellanox.com>, Daniel Borkmann <daniel@iogearbox.net>,
 Eric Dumazet <eric.dumazet@gmail.com>, Edward Cree <ecree@solarflare.com>,
 john fastabend <john.fastabend@gmail.com>, Thomas Graf <tgraf@suug.ch>,
 Johannes Berg <johannes@sipsolutions.net>, eranlinuxmellanox@gmail.com,
 Lorenzo Colitti <lorenzo@google.com>, linux-mm <linux-mm@kvack.org>,
 Robert Olsson <robert@herjulf.net>, kuznet@ms2.inr.ac.ru
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20160409172634.GA55330@ast-mbp.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 16-04-09 01:26 PM, Alexei Starovoitov wrote:

>
> yeah, no stack, no queues in bpf.

Thanks.

>
>> If this is _forwarding only_ it maybe useful to look at
>> Alexey's old code in particular the DMA bits;
>> he built his own lookup algorithm but sounds like bpf is
>> a much better fit today.
>
> a link to these old bits?
>

Dang. Trying to remember exact name (I think it has been gone for at
least 10 years now). I know it is not CONFIG_NET_FASTROUTE although
it could have been that depending on the driver (tulip had some
nice DMA properties - which by todays standards would be considered
primitive ;->).
+Cc Robert and Alexey (Trying to figure out name of driver based
routing code that DMAed from ingress to egress port)

> Just to be clear: this rfc is not the only thing we're considering.
> In particular huawei guys did a monster effort to improve performance
> in this area as well. We'll try to blend all the code together and
> pick what's the best.
>

Sounds very interesting.

cheers,
jamal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
