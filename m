From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.9-rc2 8/8] S2io: two buffer mode
Date: Fri, 15 Oct 2004 14:47:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41701B3C.8020006@pobox.com>
References: <200410150021.i9F0LJ39024214@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Raghavendra Koushik'" <raghavendra.koushik@s2io.com>,
        "'Chris Leech'" <chris.leech@gmail.com>, ravinandan.arakali@s2io.com,
        "'Francois Romieu'" <romieu@fr.zoreil.com>, netdev@oss.sgi.com,
        rapuru.sriram@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@s2io.com>
In-Reply-To: <200410150021.i9F0LJ39024214@guinness.s2io.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Leonid Grossman wrote:
>  "fragmented SKB on Rx" is an old problem - we tried to deploy 2 and 5
> buffer Xframe modes before and it did not work in Linux. 
> Is anyone aware of any network driver that successfully uses fragmented
> SKBs?

Raghavendra Koushik wrote:
> I did try fragmented SKB on Rx but it didn't seem to work. If any one can
> give me some pointers on how to get this working, I would implement 2Buff
> mode using this method and avoid a copy in fast path.



My suggestion would be to investigate why fragmented SKBs don't work ;-)

The source code is all there, debug away...

If S2IO can fix this, a lot of people will benefit.

	Jeff
