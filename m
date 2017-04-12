From: R Parameswaran <parameswaran.r7@gmail.com>
Subject: Re: [PATCH net-next v1 1/1] L2TP device MTU setup - tunnel socket
 needs a lock
Date: Wed, 12 Apr 2017 13:38:42 -0700
Message-ID: <CAGeBGG6zrCVTBnpphXc94p=FjWRbVXhH7=zfY8o73TQsRReR_A@mail.gmail.com>
References: <alpine.DEB.2.11.1704112010410.8819@nelson51.eng.vyatta.net> <20170412.101300.1946293471196203044.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        kleptog@svana.org, James Chapman <jchapman@katalix.com>,
        Nachi Prachanda <nprachan@brocade.com>,
        Robert Shearman <rshearma@brocade.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Sven-Thorsten Dietrich <sdietric@brocade.com>,
        Chas Williams III <ciwillia@brocade.com>,
        Luca Boccassi <lboccass@brocade.com>,
        Derek Fawcus <dfawcus@brocade.com>,
        Bill Hong <bhong@brocade.com>,
        Jan Blunck <jblunck@brocade.com>,
        LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170412.101300.1946293471196203044.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Please see inline:

On Wed, Apr 12, 2017 at 7:13 AM, David Miller <davem@davemloft.net> wrote:
> From: "R. Parameswaran" <parameswaran.r7@gmail.com>
> Date: Tue, 11 Apr 2017 20:14:37 -0700 (PDT)
>
>>
>> The MTU overhead calculation in L2TP device set-up
>> merged via commit b784e7ebfce8cfb16c6f95e14e8532d0768ab7ff
>> needs to be adjusted to lock the tunnel socket while
>> referencing the sub-data structures to derive the
>> socket's IP overhead.
>
> This is missing a proper signoff.
>
> The subject line also needs to be fixed "[PATCH net-next] l2tp: " as explained
> by Guillaume.
>

Thanks, I will re-spin with these corrections by tonight PT.

regards,

Ramkumar
> Thanks.
