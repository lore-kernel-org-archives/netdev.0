From: "devendra.aaru" <devendra.aaru@gmail.com>
Subject: Re: Q: NET/JME: pci_get_drvdata pointer return check at jme_remove
Date: Thu, 21 Jun 2012 10:11:04 +0530
Message-ID: <CAHdPZaOCjq1v9=sbKQwL4s8JZOqn4ZhtyBEY0CX-06s2rF1BqA@mail.gmail.com>
References: <CAHdPZaNeW3YwaJh4RYpkz2hY5n7SO9fsN8YKroCABig7ZRsU2Q@mail.gmail.com>
	<1340224238.2576.17.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:57974 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752840Ab2FUElF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 00:41:05 -0400
Received: by dady13 with SMTP id y13so309465dad.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 21:41:05 -0700 (PDT)
In-Reply-To: <1340224238.2576.17.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Thu, Jun 21, 2012 at 2:00 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Wed, 2012-06-20 at 22:50 +0530, devendra.aaru wrote:
>> Hi,
>>
>> looking at the jme_init_one error path, the context of the driver data
>> is set to null.
>>
>> If the driver unloads , the unload _remove_one, will be called and
>> deferencing the pointer, leading to a oops.
>>
>> so we need to have a check at before doing the netdev_priv at remove_one.
>>
>> Please correct me if my understanding is wrong....
>
> If a driver probe function fails for some device (i.e. its return value
> is negative), its remove function is *not* called for that device.
>
Oh, Thanks for the information, really i m a noob. i will not ask this
q's until i read some more things about the kernel and device driver
layers.
> Ben.
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>

Thanks,
Devendra
