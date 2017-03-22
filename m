From: SIMRAN SINGHAL <singhalsimran0@gmail.com>
Subject: Re: [PATCH 0/5] netfilter: Clean up tests if NULL returned on failure
Date: Wed, 22 Mar 2017 19:15:58 +0530
Message-ID: <CALrZqyOf81_Qe-sQfnqwDk4-i+R9YnB6+FOCJEZ1Q3yt6A2f3A@mail.gmail.com>
References: <1490085879-1827-1-git-send-email-singhalsimran0@gmail.com> <20170322133821.GA21278@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Greg KH <gregkh@linuxfoundation.org>,
        outreachy-kernel <outreachy-kernel@googlegroups.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170322133821.GA21278@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 22, 2017 at 7:08 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Tue, Mar 21, 2017 at 02:14:34PM +0530, simran singhal wrote:
>> This patch series clean up tests if NULL returned on failure.
>
> $ git grep "== NULL" net/netfilter/ | wc -l
> 461
>
> This is cleaning up just some of them, we still seem to have quite a
> bit of them.
>
> Main problem with this changes is that it creates lots of work to
> people backporting patches and stable maintainers, I remember that
> they have complain about this.
>
> Either way, I would prefer you fix this coding style issue in one go,
> ie. one single patch, it will be a large one.

ok, I will send the single patch.
