From: R Parameswaran <parameswaran.r7@gmail.com>
Subject: Re: [PATCH net-next v1 1/1] L2TP device MTU setup - tunnel socket
 needs a lock
Date: Wed, 12 Apr 2017 13:42:06 -0700
Message-ID: <CAGeBGG5GMOB1qi5rkOqTT2Oh+Mrv2zP0VhZSM08n_HeXgK9Jkw@mail.gmail.com>
References: <alpine.DEB.2.11.1704112010410.8819@nelson51.eng.vyatta.net> <20170412075355.mjgaerruslswcjmw@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        kleptog@svana.org, James Chapman <jchapman@katalix.com>,
        David Miller <davem@redhat.com>,
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
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170412075355.mjgaerruslswcjmw@alphalink.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guillaume,

Please see inline:

On Wed, Apr 12, 2017 at 12:53 AM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> On Tue, Apr 11, 2017 at 08:14:37PM -0700, R. Parameswaran wrote:
>>
>> The MTU overhead calculation in L2TP device set-up
>> merged via commit b784e7ebfce8cfb16c6f95e14e8532d0768ab7ff
>> needs to be adjusted to lock the tunnel socket while
>> referencing the sub-data structures to derive the
>> socket's IP overhead.
>
> Thanks.
>
> Tested-by: Guillaume Nault <g.nault@alphalink.fr>
>
> BTW, you don't need to add "v1" for the first version of a patch.
> There's also no need for numbering pathes when there's only one in the
> series. And we normally prefix the commit message with "<subsystem>: ".
> For this patch, your subject would look like " [PATCH net-next] l2tp: ...".
>
> Also, you could have added a "Reported-by:" tag (I don't really mind
> in this case, but that's good practice).

Thanks for correcting these (and for testing the changes) and sorry
for the Reported-by omission. I'll respin by tonight
with these, per reply to Dave.

regards,

Ramkumar
