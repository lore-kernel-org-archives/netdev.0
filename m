From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCHv2] am33xx: cpsw: default to ethernet hwaddr from efuse if
 not defined in dt
Date: Thu, 5 Sep 2013 13:22:34 -0700
Message-ID: <CAOesGMj7t4WAGtcE+PUau0OhANoGNdokCHpUoNF2t+hs+83iCg@mail.gmail.com>
References: <871u70bd95.fsf@dell.be.48ers.dk>
	<20130905201637.GB10973@ohporter.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Peter Korsgaard <jacmet@sunsite.dk>,
	Mark Jackson <mpfj-list@newflow.co.uk>,
	Tony Lindgren <tony@atomide.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	linux-omap <linux-omap@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>, hvaibhav@ti.com,
	Richard Cochran <richardcochran@gmail.com>,
	Kevin Hilman <khilman@linaro.org>, michal.bachraty@gmail.com,
	michal.bachraty@streamunlimited.com
To: Matt Porter <matt.porter@linaro.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20130905201637.GB10973@ohporter.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 5, 2013 at 1:16 PM, Matt Porter <matt.porter@linaro.org> wrote:
> On Mon, Jul 15, 2013 at 07:31:18AM +0200, Peter Korsgaard wrote:
>> >>>>> "Mark" == Mark Jackson <mpfj-list@newflow.co.uk> writes:
>>
>> Hi,
>>
>>  Mark> On 08/07/13 13:42, Mark Jackson wrote:
>>  >> On 18/01/13 05:14, Mugunthan V N wrote:
>>  >>> On 1/18/2013 3:48 AM, Peter Korsgaard wrote:
>>  >>>> When booting with CONFIG_ARM_APPENDED_DTB (either because of using an old
>>  >>>> U-Boot, not wanting the hassle of 2 files or when using Falcon fast boot
>>  >>>> mode in U-Boot), nothing updates the ethernet hwaddr specified for the
>>  >>>> CPSW slaves, causing the driver to use a random hwaddr, which is some times
>>  >>>> troublesome.
>>  >>>>
>>  >>>> The am33xx has unique ethernet hwaddrs programmed in the efuse, so it makes
>>  >>>> more sense to default to these rather than random ones. Add a fixup step
>>  >>>> which adds mac-address dt properties using the efuse addresses if the DTB
>>  >>>> didn't contain valid ones.
>>  >>>>
>>  >>>> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
>>  >>>
>>  >>> This implementation looks fine.
>>  >>> Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
>>  >>
>>  >> Tested-by: Mark Jackson <mpfj-list@newflow.co.uk>
>>
>>  Mark> Is this ever going to be put into the mainline code ?
>>
>> Good question. Tony, could you please pick this up? It has been pending
>> since January and has a number of acks.
>>
>> Do you want me to resend?
>
> Also working nicely here on 3.11.
>
> Tested-by: Matt Porter <matt.porter@linaro.org>
>
> Kevin or Olof: can you apply? Seems to be continuing no response after
> Ack back in January.

I have no idea what the patch is, it's no longer in the email. Can you
resend it, please?


-Olof
