From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] genetlink: fix unsigned int comparison with less than
 zero
Date: Sun, 13 Nov 2016 08:31:44 +0100
Message-ID: <1479022304.4897.0.camel@sipsolutions.net>
References: <20161110155758.26996-1-colin.king@canonical.com>
         <CAM_iQpW=q4nm97dNouSL19Cr2cEWT9xQHXAm4CNJk=AY8z_2MA@mail.gmail.com>
         <1478986636.4226.4.camel@sipsolutions.net>
         <CAM_iQpUw-PYmksL2StciJiM-8C+y3w9T_Vo4=pVKnjQzTwKvLg@mail.gmail.com>
         (sfid-20161113_062527_710881_19064851)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Colin King <colin.king@canonical.com>,
        "David S . Miller" <davem@davemloft.net>,
        pravin shelar <pshelar@ovn.org>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        Florian Westphal <fw@strlen.de>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpUw-PYmksL2StciJiM-8C+y3w9T_Vo4=pVKnjQzTwKvLg@mail.gmail.com> (sfid-20161113_062527_710881_19064851)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > I suppose it could be, since family IDs are allocated in a 16-bit
> > range
> > anyway. But family IDs can also never actually be negative, so
> > having
> > an unsigned int in the struct makes sense too.
> 
> All idr_* API's accept int, rather than unsigned int. This is my
> point.

Sure, but that's an internal implementation detail. The struct
genl_family is also an external API towards its users, and there
negative numbers make no sense whatsoever.

johannes
