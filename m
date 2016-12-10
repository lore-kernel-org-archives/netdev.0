From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 37/50] netfilter: nf_tables: atomic dump and reset for
 stateful objects
Date: Sat, 10 Dec 2016 13:21:52 +0100
Message-ID: <20161210122152.GA4653@salvia>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
 <1481147576-5690-38-git-send-email-pablo@netfilter.org>
 <CAP=VYLp-ZBFjR1W9=V_vyPYAi1=Yub3ugq6D8hkoLigcPaaxFg@mail.gmail.com>
 <20161209102432.GA986@salvia>
 <1481293492.4930.168.camel@edumazet-glaptop3.roam.corp.google.com>
 <1481296926.4930.171.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
        netfilter-devel@vger.kernel.org,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1481296926.4930.171.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 09, 2016 at 07:22:06AM -0800, Eric Dumazet wrote:
> On Fri, 2016-12-09 at 06:24 -0800, Eric Dumazet wrote:
> 
> > It looks that you want a seqcount, even on 64bit arches,
> > so that CPU 2 can restart its loop, and more importantly you need
> > to not accumulate the values you read, because they might be old/invalid.
> 
> Untested patch to give general idea. I can polish it a bit later today.

I'm preparing a patch now, so you can review it.

Eric, thanks a lot for reviewing and proposing a working approach!
