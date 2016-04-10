From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH v2 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Sun, 10 Apr 2016 14:09:03 -0400
Message-ID: <570A96BF.5080608@mojatatu.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
 <20160408123614.2a15a346@redhat.com> <20160408143340.10e5b1d0@redhat.com>
 <20160408172651.GA38264@ast-mbp.thefacebook.com>
 <20160408220808.682630d7@redhat.com>
 <20160408213414.GA43408@ast-mbp.thefacebook.com>
 <CALx6S36d74D-8Rx762nmNwb1TF0M0sBfojBhUF96prJiYmDYiQ@mail.gmail.com>
 <57091FCE.50104@mojatatu.com>
 <20160409172634.GA55330@ast-mbp.thefacebook.com>
 <20160410075550.GA22873@pox.localdomain>
 <CALx6S37gzDE0-S4JjS3m+FyuA2xypyp+O+XYdeK3ciAnvmmkyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
 Jesper Dangaard Brouer <brouer@redhat.com>,
 Brenden Blanco <bblanco@plumgrid.com>, "David S. Miller"
 <davem@davemloft.net>,
 Linux Kernel Network Developers <netdev@vger.kernel.org>,
 Or Gerlitz <ogerlitz@mellanox.com>, Daniel Borkmann <daniel@iogearbox.net>,
 Eric Dumazet <eric.dumazet@gmail.com>, Edward Cree <ecree@solarflare.com>,
 john fastabend <john.fastabend@gmail.com>,
 Johannes Berg <johannes@sipsolutions.net>, eranlinuxmellanox@gmail.com,
 Lorenzo Colitti <lorenzo@google.com>, linux-mm <linux-mm@kvack.org>
To: Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <CALx6S37gzDE0-S4JjS3m+FyuA2xypyp+O+XYdeK3ciAnvmmkyQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 16-04-10 12:53 PM, Tom Herbert wrote:

> We started discussions about this in IOvisor. The Huawei project is
> called ceth (Common Ethernet). It is essentially a layer called
> directly from drivers intended for fast path forwarding and network
> virtualization. They have put quite a bit of effort into buffer
> management and other parts of the infrastructure, much of which we
> would like to leverage in XDP. The code is currently in github, will
> ask them to make it generally accessible.
>

Cant seem to find any info on it on the googles.
If it is forwarding then it should hopefully at least make use of Linux
control APIs I hope.

cheers,
jamal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
