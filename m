From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [GIT] Networking
Date: Thu, 21 Feb 2013 21:26:19 -0500
Message-ID: <CAP=VYLoW2KfdWen6x0p+Kv_DbsDj=mHMdAZB5Mx_RkFZ7jk6fg@mail.gmail.com>
References: <20130220.170901.343210063003534302.davem@davemloft.net>
 <CA+55aFz=tzf9a-SY1CqCAxsqRDz=ebE69YoZ30at6kHeKKhsaA@mail.gmail.com> <5126313E.2060608@start.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Mark Lord <kernel@start.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5126313E.2060608@start.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 21, 2013 at 9:37 AM, Mark Lord <kernel@start.ca> wrote:
> On 13-02-20 10:05 PM, Linus Torvalds wrote:
>> On Wed, Feb 20, 2013 at 2:09 PM, David Miller <davem@davemloft.net> wrote:
>>>
>>> 15) Orphan and delete a bunch of pre-historic networking drivers from
>>>     Paul Gortmaker.
>>
>> Nooo.... You killed the 3c501 and 3c503 drivers! Snif.
>>
>> I wonder if they still worked..
>
> I hope they're not really dead, because we still use them in several machines here
> as secondary interfaces for test rigs and whatnot.
>
> It's a tad early to be nuking support for such widespread devices.

Hi Mark,

Did you actually look at the drivers deleted?  This was not a blanket
delete of _all_ ISA drivers, and I seriously doubt that you are using the
3c501 or 3c503 drivers.  To be clear, it was a very selective removal of
drivers from the early 1990's, and so the common ISA drivers for the
widespread devices (like 3c509, and 8390 shared memory implementations)
continue to exist in mainline today.

Someday we will delete them, but it was not done here at this point in
time, so I hope people do not get confused on that.

Paul.
--

>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
