From: Daniel Mack <zonque@gmail.com>
Subject: Re: ethernet: ti: cpsw/mdio: suspend/resume
Date: Thu, 15 Aug 2013 12:04:19 +0200
Message-ID: <520CA7A3.60305@gmail.com>
References: <520BECA2.90800@gmail.com> <520CA61F.3050802@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Vaibhav Bedia <vaibhav.bedia@ti.com>, netdev@vger.kernel.org,
	Sebastian Siewior <bigeasy@linutronix.de>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:59812 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753393Ab3HOKEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 06:04:22 -0400
Received: by mail-ee0-f42.google.com with SMTP id b45so262473eek.29
        for <netdev@vger.kernel.org>; Thu, 15 Aug 2013 03:04:21 -0700 (PDT)
In-Reply-To: <520CA61F.3050802@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.08.2013 11:57, Mugunthan V N wrote:
> On Thursday 15 August 2013 02:16 AM, Daniel Mack wrote:
>> Vaibhav told me that you are working on a patch to add suspend/resume
>> functions to the cpsw and davinci_mdio driver, but searching my archives
>> didn't bring up anything.
>>
>> May I ask whether you have a link to your work, or can I help here in
>> any way?
>>
>>
>> Thanks,
>> Daniel
> Sorry for re-posting the same mail as my previous mail was in html format
> 
> Thanks for your helping hand. All my patches for CPSW suspend/resume had
> already applied

You're talking about the pinctrl related patches, right?

> and with Dave Gerlach AM335x suspend/resume patches CPSW
> suspend/resume works fine. Dave Gerlach has his branch published at
> below link which I had already tested suspend.resume with CPSW ping traffic.
> https://github.com/dgerlach/linux-pm/tree/am335x-3.11rc4-suspend-resume

Hmm, I'm testing with this tree as well, and at least when mounting the
rootfs via NFS, ethernet is dead after resume. But I'll do more tests
soon and let you know. I just thought I'm missing some patch.


Thanks for the update,
Daniel
