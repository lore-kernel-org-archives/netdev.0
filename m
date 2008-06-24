From: "Bryan Wu" <cooloney@kernel.org>
Subject: Re: [patch v2 02/11] DM9000: Fixup blackfin after removing 2 resource usage
Date: Tue, 24 Jun 2008 10:00:26 +0800
Message-ID: <386072610806231900s32cb5a9cide29f1a29034ab88@mail.gmail.com>
References: <20080622201645.041001353@fluff.org.uk>
	 <20080622201904.747948172@fluff.org.uk>
	 <20080622203530.GB4050@solarflare.com>
	 <20080623092407.GD26276@fluff.org.uk>
	 <386072610806230256h14679adcwb1e4e27a06539f1a@mail.gmail.com>
	 <20080623102056.GO18367@trinity.fluff.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, jeff@garzik.org,
	"Laurent Pinchart" <laurentp@cse-semaphore.com>
To: "Ben Dooks" <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:1971 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbYFXCA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 22:00:27 -0400
Received: by rv-out-0506.google.com with SMTP id k40so7378495rvb.1
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 19:00:26 -0700 (PDT)
In-Reply-To: <20080623102056.GO18367@trinity.fluff.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 23, 2008 at 6:20 PM, Ben Dooks <ben-linux@fluff.org> wrote:
> On Mon, Jun 23, 2008 at 05:56:08PM +0800, Bryan Wu wrote:
>> On Mon, Jun 23, 2008 at 5:24 PM, Ben Dooks <ben-linux@fluff.org> wrote:
>> > On Sun, Jun 22, 2008 at 09:35:32PM +0100, Ben Hutchings wrote:
>> >> Ben Dooks wrote:
>> >> > From: Laurent Pinchart <laurentp@cse-semaphore.com>
>> >> >
>> >> > The dm9000 driver accepts either 2 or 3 resources to describe the platform
>> >> > devices. The 2 resources case abuses the ioresource mechanism by passing
>> >> > ioremap()ed memory through the platform device resources. This patch removes
>> >> > converts boards that were using it to the 3 resources scheme.
>> >> [...]
>> >>
>> >> This needs to be applied before the previous patch, otherwise there's
>> >> a point where these boards are broken.
>> >
>> > There may be a small overlap, but I'd much rather fix the abuse than
>> > actually leave it in there much longer. The fixup patch has been cc'd
>> > to the blackfin maintainer, so any breakage will be minimal (and will
>> > also be clearly marked, it isn't as if the driver will just fail to
>> > work; there is a clear error being printed and it will gracefully
>> > exit).
>> >
>> > --
>>
>> I agree with Ben Hunchings here.
>>
>> Because this patch depends on previous patches in this series, could
>> you please merge this patch set as a whole DM9000 series?
>> If I merge this patch from Blackfin subsystem, there will be some
>> breakage before other DM9000 patches are merged.
>> So please merge this Blackfin fixup patch with other DM9000 patches together.
>>
>> And This patch is OK for Blackfin change.
>
> Hmm, if the patch depends on the previous one, then the three resource
> case for blackfin is broken, and will remain broken after this. The changes
> in arch/blackfin should be applyable before the removal of the two-resource
> case from the dm9000 driver?
>

Exactly, I do think so. I met similar conflict in serial tty driver updates.

> If you are happy with these changes to be merged via the netdev trees, then
> I'm sure that applying this entire set as-is would be fine with the network
> device maintainers.
>

I'd love to see that. Thanks.

-Bryan
