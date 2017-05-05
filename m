From: Amir Goldstein <amir73il@gmail.com>
Subject: Re: [PATCH v1] ACPI: Switch to use generic UUID API
Date: Fri, 5 May 2017 12:50:31 +0300
Message-ID: <CAOQ4uxjErce01+xyDnM=nCJS+avQ4g6hQVvH3fVotj7Ws2moCQ@mail.gmail.com>
References: <20170504092151.88646-1-andriy.shevchenko@linux.intel.com>
 <CAPcyv4jzD0MEBRNTwTokVzgdDWas682ArUjRAGT1hp=QRE8Pjg@mail.gmail.com>
 <CAOQ4uxjha8_2_HwgdgBN=G-vNytAW5Gk155E9z8OWyFiGNEZVw@mail.gmail.com> <1493976265.30052.21.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dan Williams <dan.j.williams@intel.com>,
        Linux ACPI <linux-acpi@vger.kernel.org>,
        tpmdd-devel@lists.sourceforge.net, intel-gfx@lists.freedesktop.org,
        nouveau@lists.freedesktop.org, linux-input@vger.kernel.org,
        iommu@lists.linux-foundation.org, linux-mmc@vger.kernel.org,
        Netdev <netdev@vger.kernel.org>, linux-pci@vger.kernel.org,
        USB list <linux-usb@vger.kernel.org>,
        alsa-devel@alsa-project.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Rafael J . Wysocki" <rjw@rjwysocki.net>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        Borislav Petkov <bp@suse.de>,
        Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
        Jani Nikula <jani.nikula@linux.intel.com>,
        Ben Skeggs <bskeggs@redhat.com>,
        Benjamin Tissoires <benjamin.tissoires@redhat.com>,
        Joerg
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1493976265.30052.21.camel@linux.intel.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 5, 2017 at 12:24 PM, Andy Shevchenko
<andriy.shevchenko@linux.intel.com> wrote:
> On Fri, 2017-05-05 at 10:06 +0300, Amir Goldstein wrote:
[...]
>> I think with this semantic change, our proposals can reach common
>> grounds
>> and satisfy a wider group of users (i.e. filesystem developers).
>>
>> Christoph also suggested a similar treatment to typedef guid_t to
>> struct uuid_le.
>> I don't know the use cases enough to comment on that.
>
> We may go this way. But I wouldn't prevent current users of uuid_le to
> continue using it without conversion (it may be done case by case after
> we settle an API)
>
> So, summarize what Christoph said it will look like
>
> typedef uuid_be uuid_t;
> typedef uuid_le guid_t
>
> uuid_cmp() / uuid_copy() / uuid_to_bin() / etc
> guid_cmp() / guid_copy() / guid_to_bin() / etc
>
> Correct? Christoph?
>

That looks right to me.

To complete the picture for folks not cc'ed on my patches,
xfs use case suggests there is also justification for the additional helpers:

uuid_is_null() / uuid_equal()
guid_is_null() / guid_equal()

Cheers,
Amir.
