From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH] mac80211: port CCMP to cryptoapi's CCM driver
Date: Tue, 8 Oct 2013 14:20:28 +0200
Message-ID: <CAKv+Gu_9th7+tRYe7LCsk1hPhaU=MrZqsGJpTOKHX-PW+z1_BQ@mail.gmail.com>
References: <1381231915-24232-1-git-send-email-ard.biesheuvel@linaro.org>
	<1381233152.13359.10.camel@jlt4.sipsolutions.net>
	<CAKv+Gu9-ddqyuGg=NDFoWzNko+0uMG_po6WnzTc7g3DAzx=_dQ@mail.gmail.com>
	<1381234564.13359.11.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Patch Tracking <patches@linaro.org>,
	John Linville <linville@tuxdriver.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:58415 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050Ab3JHMU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 08:20:29 -0400
Received: by mail-la0-f46.google.com with SMTP id eh20so6724016lab.19
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 05:20:28 -0700 (PDT)
In-Reply-To: <1381234564.13359.11.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8 October 2013 14:16, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Tue, 2013-10-08 at 14:00 +0200, Ard Biesheuvel wrote:
>
>> BTW I should probably have mentioned that this is fully tested code:
>> my zd1211 works happily with it using pairwise CCMP with no
>> regressions in performance.
>
> Good to know. Not that I think zd1211 is a good device for performance
> tests (you'd have to measure CPU utilisation in some way), but
> ultimately it doesn't really matter as all the high-performance devices
> need hardware crypto anyway.
>

I agree. I am not saying the typical performance of a zd1211 is a
meaningful quantity, just that this particular device performs
identically before and after applying this patch, which suggests that
it is not creating lots of corrupted frames or messing up the
authentication.

Regards,
-- 
Ard.
