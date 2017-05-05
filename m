From: Amir Goldstein <amir73il@gmail.com>
Subject: Re: [PATCH v1] ACPI: Switch to use generic UUID API
Date: Fri, 5 May 2017 13:02:21 +0300
Message-ID: <CAOQ4uxg6+_0KRMkMyupFJDtXrTqxx8vOz3=ZyEuj8BakvfuEJQ@mail.gmail.com>
References: <20170504092151.88646-1-andriy.shevchenko@linux.intel.com>
 <CAPcyv4jzD0MEBRNTwTokVzgdDWas682ArUjRAGT1hp=QRE8Pjg@mail.gmail.com>
 <CAOQ4uxjha8_2_HwgdgBN=G-vNytAW5Gk155E9z8OWyFiGNEZVw@mail.gmail.com>
 <1493976265.30052.21.camel@linux.intel.com> <CAOQ4uxjErce01+xyDnM=nCJS+avQ4g6hQVvH3fVotj7Ws2moCQ@mail.gmail.com>
 <20170505095739.GB6762@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Dan Williams <dan.j.williams@intel.com>,
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
        Benj
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170505095739.GB6762@lst.de>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 5, 2017 at 12:57 PM, Christoph Hellwig <hch@lst.de> wrote:
> On Fri, May 05, 2017 at 12:50:31PM +0300, Amir Goldstein wrote:
>> To complete the picture for folks not cc'ed on my patches,
>> xfs use case suggests there is also justification for the additional helpers:
>>
>> uuid_is_null() / uuid_equal()
>> guid_is_null() / guid_equal()
>
> The is_null is useful and I bet we'll find other instances. I'm
> not sure _equals really adds much value over the existing _cmp
> helpers, but on the other hand they are so trivial that we might as
> well add them.

Exactly. The fact that not only xfs used the same helper name
(drivers/md/md.c) suggests that it useful.

>
> The other thing XFS has is uuid_copy.

Andy already listed uuid_copy.
