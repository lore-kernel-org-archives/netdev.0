From: "Torne (Richard Coles)" <torne@google.com>
Subject: Re: [PATCH] r8169: Randomise invalid MAC addresses
Date: Mon, 23 Jan 2012 21:35:12 +0000
Message-ID: <CAEV-rjeC1NwbUwdmEEquGf7S8uttsW5hwTjF5nTC_JXY7=OC9A@mail.gmail.com>
References: <1327343540-30348-1-git-send-email-torne@google.com>
	<CAP=VYLqpUun0FtCs4VWDeLm-mAri=+UV3psRA12eVbV1So_c-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nic_swsd@realtek.com, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAP=VYLqpUun0FtCs4VWDeLm-mAri=+UV3psRA12eVbV1So_c-Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23 January 2012 20:53, Paul Gortmaker <paul.gortmaker@gmail.com> wrote:
> On Mon, Jan 23, 2012 at 1:32 PM, Torne (Richard Coles) <torne@google.com> wrote:
>> From: "Torne (Richard Coles)" <torne@google.com>
>>
>> If the default MAC address stored in the card is invalid, replace it
>> with a random address and complain about it.
>
> You might want to have a look at this thread and its outcome.
>
> https://lkml.org/lkml/2012/1/14/75

While I can appreciate the argument that people shouldn't build
hardware that relies on this kind of behaviour, I am in the same
situation as Darren there: I have a retail device I have bought that
has a garbage MAC address (an OpenPeak Joggler), and so do all the
others. Requiring that this be worked around in userspace makes it
tricky to just install a standard Linux distribution onto this piece
of hardware that's otherwise pretty much x86-pc-compatible (albeit
with a weird bootloader)

The vendor's distribution clones the USB wifi adapter's MAC onto the
ethernet device in userspace at boot, which is rather unpleasant (it
never uses both interfaces at once, admittedly).

So, is this just not going to be acceptable in any form? What about
refactoring the existing drivers that do this so that this code
doesn't need to be repeated in every driver, if that would help? I'd
really quite like to get standard linux distros to be compatible with
the Joggler, and this is one of the few changes that's actually needed
(one way or another).

-- 
Torne (Richard Coles)
torne@google.com
