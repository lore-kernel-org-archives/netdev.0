From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: lib: Introduce priority array area manager
Date: Thu, 23 Feb 2017 10:25:54 +0100
Message-ID: <20170223092554.GB2699@nanopsycho>
References: <20170222190204.878696619DE@gitolite.kernel.org>
 <CAMuHMdXR5QZrN1NMkZq_jSo0cRMqMJ6m5q-8C3pr1_NWKUZcqg@mail.gmail.com>
 <20170223083231.GA2699@nanopsycho>
 <CAMuHMdV4-xfKyBiBU2GaR42MA_5LjspF-wykN=ADgEdF6X+wWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdV4-xfKyBiBU2GaR42MA_5LjspF-wykN=ADgEdF6X+wWg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, Feb 23, 2017 at 10:22:22AM CET, geert@linux-m68k.org wrote:
>Hi Jiri,
>
>On Thu, Feb 23, 2017 at 9:32 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Thu, Feb 23, 2017 at 08:56:26AM CET, geert@linux-m68k.org wrote:
>>>On Wed, Feb 22, 2017 at 8:02 PM, Linux Kernel Mailing List
>>><linux-kernel@vger.kernel.org> wrote:
>>>> Web:        https://git.kernel.org/torvalds/c/44091d29f2075972aede47ef17e1e70db3d51190
>>>> Commit:     44091d29f2075972aede47ef17e1e70db3d51190
>>>> Parent:     b862815c3ee7b49ec20a9ab25da55a5f0bcbb95e
>>>> Refname:    refs/heads/master
>>>> Author:     Jiri Pirko <jiri@mellanox.com>
>>>> AuthorDate: Fri Feb 3 10:29:06 2017 +0100
>>>> Committer:  David S. Miller <davem@davemloft.net>
>>>> CommitDate: Fri Feb 3 16:35:42 2017 -0500
>>>>
>>>>     lib: Introduce priority array area manager
>>>>
>>>>     This introduces a infrastructure for management of linear priority
>>>>     areas. Priority order in an array matters, however order of items inside
>>>>     a priority group does not matter.
>>>>
>>>>     As an initial implementation, L-sort algorithm is used. It is quite
>>>>     trivial. More advanced algorithm called P-sort will be introduced as a
>>>>     follow-up. The infrastructure is prepared for other algos.
>>>>
>>>>     Alongside this, a testing module is introduced as well.
>>>>
>>>>     Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>>>
>>>> --- a/lib/Kconfig
>>>> +++ b/lib/Kconfig
>>>> @@ -550,4 +550,7 @@ config STACKDEPOT
>>>>  config SBITMAP
>>>>         bool
>>>>
>>>> +config PARMAN
>>>> +       tristate "parman"
>>>
>>>| parman (PARMAN) [N/m/y] (NEW) ?
>>>|
>>>| There is no help available for this option.
>>>
>>>Can you please add a description for this option?
>>>Or drop the "parman" string if this is always selected by its kernel users, and
>>>never intended to be enabled by the end user.
>>
>> I did it in the same way other similar lib dependencies do that. Does
>> not make sense to have separate description for this, cause this is
>> always only a dependency of a kernel user.
>
>OK, so the user should not be asked about it...
>
>> You suggeste to 'drop the "parman" string'. What do you mean by that
>> exactly?
>
>... and
>
>-       tristate "parman"
>+       tristate
>
>should do the trick.

Okay. I will push this through the net tree. Thanks!
