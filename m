From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Re: Regarding group_forward_mask in bridge in 3.4 kernel
Date: Tue, 18 Sep 2012 14:00:39 +0530
Message-ID: <CADAe=+JQTvY6eXH=UCTUSXER0fTND0YQUY4astzo0MVB6-T8qA@mail.gmail.com>
References: <CADAe=++yAm3t-ZqMKy9h-Rda5=pOYQD2-cKUd3S1VKmBZQfT9A@mail.gmail.com>
 <505740C1.9080706@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:61116 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756746Ab2IRIbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 04:31:10 -0400
Received: by oago6 with SMTP id o6so5760964oag.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 01:31:09 -0700 (PDT)
In-Reply-To: <505740C1.9080706@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the reply John.

Then in the case of Link Aggregation whose mac-address is
01-80-c2-00-00-02 I should do

echo 4 >> /sys/class/net/...

But value 4 is not getting accepted. why ?

Regards,
Ajith
--------------------------------------------
codingfreak.in


On Mon, Sep 17, 2012 at 8:54 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> wrong value see the logic you quoted use 1 << 8
>
> echo 256 > /sys/class/net/...
>
> Your example fwds non-TPMR addresses 01-80-c2-00-00-03.
