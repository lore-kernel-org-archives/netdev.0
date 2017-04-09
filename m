From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH] net: netfilter: Replace explicit NULL comparisons
Date: Sun, 9 Apr 2017 10:26:41 +0200 (CEST)
Message-ID: <nycvar.YFH.7.76.1704091025350.18194@n3.vanv.qr>
References: <20170408172113.GA9352@arushi-HP-Pavilion-Notebook> <nycvar.YFH.7.76.1704082020530.14011@n3.vanv.qr> <20170408201438.GC2679@salvia> <CA+XqjF_8=+GB7oq6wKoxk_+FfPeni+tLaVMAE6k6tP-KOOEi6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+XqjF_8=+GB7oq6wKoxk_+FfPeni+tLaVMAE6k6tP-KOOEi6Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sunday 2017-04-09 05:42, Arushi Singhal wrote:
>On Sun, Apr 9, 2017 at 1:44 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>      On Sat, Apr 08, 2017 at 08:21:56PM +0200, Jan Engelhardt wrote:
>      > On Saturday 2017-04-08 19:21, Arushi Singhal wrote:
>      >
>      > >Replace explicit NULL comparison with ! operator to simplify code.
>      >
>      > I still wouldn't do this, for the same reason as before. Comparing to
>      > NULL explicitly more or less gave an extra guarantee that the other
>      > operand was also a pointer.
>
>      Arushi, where does it say in the coding style that this is prefered? 
>
>This is reported by checkpatch.pl script.

checkpatch has been controversial at times, like when people took the 80
character limit way too literally. Changing pointer comparisons looks like
another thing that is better left ignored.
