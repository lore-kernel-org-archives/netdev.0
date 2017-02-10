From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v4] net: ethernet: faraday: To support device tree usage.
Date: Fri, 10 Feb 2017 09:03:06 -0600
Message-ID: <CAL_Jsq+W=gXRYTuEAwdXfKvRsUY559zAp2tstGxdrF0BzAhQKQ@mail.gmail.com>
References: <20170124084606.GA11764@app09> <20170125.123448.742815192519658537.davem@davemloft.net>
 <CAK8P3a2Zr6=4x8JRa313DQ2ND0V=8eL0yKkrd93wbdxkiOtmSw@mail.gmail.com>
 <20170127221733.tcoudehkp5b5jnfw@rob-hp-laptop> <CAEbi=3fZddPR8L+B6gW+yUraAK_wu=4oOyk3ff-Ez-Qy-LEBfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Mark Rutland <mark.rutland@arm.com>
To: Greentime Hu <green.hu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEbi=3fZddPR8L+B6gW+yUraAK_wu=4oOyk3ff-Ez-Qy-LEBfQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 8, 2017 at 5:59 AM, Greentime Hu <green.hu@gmail.com> wrote:
> On Sat, Jan 28, 2017 at 6:17 AM, Rob Herring <robh@kernel.org> wrote:
>>
>> On Wed, Jan 25, 2017 at 10:09:20PM +0100, Arnd Bergmann wrote:
>> > On Wed, Jan 25, 2017 at 6:34 PM, David Miller <davem@davemloft.net> wrote:
>> > > From: Greentime Hu <green.hu@gmail.com>
>> > > Date: Tue, 24 Jan 2017 16:46:14 +0800
>> > >> We also use the same binding document to describe the same faraday ethernet
>> > >> controller and add faraday to vendor-prefixes.txt.
>> > >
>> > > Why are you renaming the MOXA binding file instead of adding a completely new one
>> > > for faraday?  The MOXA one should stick around, I don't see a justification for
>> > > removing it.
>> >
>> > This was my suggestion, basically fixing the name of the existing
>> > binding, which was
>> > accidentally named after one of the users rather than the company that did the
>> > hardware.
>> >
>> > We can't change the compatible string, but I'd much prefer having only
>> > one binding
>> > file for this device rather than two separate ones that could possibly become
>> > incompatible in case we add new properties to them. If there is only
>> > one of them,
>> > naming it according to the hardware design is the general policy.
>> >
>> > Note that we currently have two separate device drivers, but that is more a
>> > historic artifact, and if we ever get around to merging them into one driver,
>> > that should not impact the binding.
>>
>> The change is fine with me, but the subject and commit message need some
>> work.
>
> Hi, Rob:
>
> Would you please advise me of the proper subject and commit messages?

Split the binding to a separate commit and summarize the email
discussion here. For a subject, something like this:

"dt-bindings: net: generalize moxart-mac to support all faraday based ftmac IP"

Rob
