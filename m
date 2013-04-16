From: Alex Stahl <testcore@gmail.com>
Subject: Re: How to file a bug against iproute2?
Date: Tue, 16 Apr 2013 13:52:54 -0700
Message-ID: <CAAc8SH4_pSWzQteEub31hkHFuLmWdJ8=F+y0_XzxJrmLygUdaw@mail.gmail.com>
References: <CAAc8SH5MjWdcFbkmV5uJgUv7nr_PN8n99azV4ZKxL3EKJ9Vthg@mail.gmail.com>
	<1366140759.2645.26.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:46583 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753767Ab3DPUwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 16:52:55 -0400
Received: by mail-ie0-f182.google.com with SMTP id at1so1111610iec.27
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 13:52:54 -0700 (PDT)
In-Reply-To: <1366140759.2645.26.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, Ben.

I'll be going back to userland now.

On Tue, Apr 16, 2013 at 12:32 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Tue, 2013-04-16 at 12:05 -0700, Alex Stahl wrote:
>> Hi Folks - Apologies in advance if this is the wrong forum for this...
>> I'd like to file a bug against iproute2 related to a permissions
>> issue, but can't find the bug tracker.
>
> This list is the bug tracker.
>
> [...]
>> According to the arch wiki, if I'm in the 'network' group I should be
>> able to manipulate interfaces:
>>
>> https://wiki.archlinux.org/index.php/Groups#Group_list
> [...]
>
> That's talking about what groups should be used for access control by
> daemons and in the filesystem.  As far as the kernel is concerned,
> network configuration depends on the CAP_NET_ADMIN capability, not group
> membership.
>
> Ben.
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
