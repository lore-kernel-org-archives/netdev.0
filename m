From: "Chris Peterson" <cpeterso@cpeterso.com>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 13:01:36 -0700
Message-ID: <a24804730805151301s3c6644d0hc2c78b8008fe035d@mail.gmail.com>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>
	 <20080515142154.0595e475@core>
	 <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>
	 <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com>
	 <482C8184.2030906@garzik.org> <482C8550.5000909@intel.com>
	 <482C8D4D.3040702@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Rick Jones" <rick.jones2@hp.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764295AbYEOUBy@vger.kernel.org>
In-Reply-To: <482C8D4D.3040702@garzik.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please correct me if I'm wrong, but this thread's conclusions seem to be:

* network interrupts are an inappropriate source of entropy (see my patch)
* headless servers need entropy, but should seek a better solution,
such as EGD, hardware RNG, or other kernel entropy sources (but that
is a separate task)
* TPM RNG is a separate task and, if implemented, should be in
drivers/char/hw_random/


chris


On Thu, May 15, 2008 at 12:21 PM, Jeff Garzik <jeff@garzik.org> wrote:
> Kok, Auke wrote:
>>
>> How about the non-NAPI and non-throttled case? I would argue that without
>> any irq
>> mitigation we can still use SA_RANDOM. Many (e.g. embedded) devices will
>> want some
>
> When was the last time we added a new driver for new hardware, and it didn't
> support NAPI and/or hw mitigation?  They are few and far between, and
> getting ever more rare.
>
>
>> extra form of entropy, and providing them it in this form will be very
>> beneficial
>> as these devices more commonly have no other form of entropy anymore.
>
> "no other form of entropy"?   See examples in this thread.
>
>        Jeff
>
>
>
