From: Ani Sinha <ani@arista.com>
Subject: Re: linux 3.4.43 : kernel crash at __nf_conntrack_confirm
Date: Wed, 21 Oct 2015 14:26:35 -0700
Message-ID: <CAOxq_8PLX_+w-7mfx1Agh+utogEiFWHSmEFd0Bax1LY6qbEN-w@mail.gmail.com>
References: <CAOxq_8PF91fpX9jYTgBbXnOVeVfSu3tytu-3P_Zr5OodGRoz+g@mail.gmail.com>
 <CAOxq_8Pt7VMwkV8+wdjS9vj=-L0L8Xxkd3Beit0zZN_oR6ixhw@mail.gmail.com>
 <20151018080702.GA14564@breakpoint.cc> <CAOxq_8P9Qgy5+qWNCHtbG8qJwfdKSO3ZiDWoQW_6BVS-+hcTRA@mail.gmail.com>
 <20151021211911.GD31323@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20151021211911.GD31323@breakpoint.cc>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 21, 2015 at 2:19 PM, Florian Westphal <fw@strlen.de> wrote:
> Ani Sinha <ani@arista.com> wrote:
>> >> > commit c6825c0976fa7893692e0e43b09740b419b23c09
>> >> > Author: Andrey Vagin <avagin@openvz.org>
>> >> > Date:   Wed Jan 29 19:34:14 2014 +0100
>> >> >      netfilter: nf_conntrack: fix RCU race in nf_conntrack_find_get
>> >> >
>> >> > and a followup patch :
>> >> >
>> >> > commit e53376bef2cd97d3e3f61fdc677fb8da7d03d0da
>> >> > Author: Pablo Neira Ayuso <pablo@netfilter.org>
>> >> > Date:   Mon Feb 3 20:01:53 2014 +0100
>> >> >         netfilter: nf_conntrack: don't release a conntrack with non-zero refcnt
>> >> >
>> >
>> > These for instance fix such bugs.
>>
>> So since both these patches were not backported to 3.4 series and
>> since now we have evidence of a crash that points to issues which the
>> patches fix, should we consider backporting the above patches to 3.4?
>
> Yes.

Ok cool. I will send out backport patches for 3.4 corresponding to
both the above patches.
