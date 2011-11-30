From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [MAC802154] DRAFT: IEEE 802.15.4 MAC layer basic implementation
Date: Wed, 30 Nov 2011 20:13:53 +0400
Message-ID: <CALT56yPPXzVH9Mb6LznEyRv42wgGWK_P7Yf8cbWywD4HXtFGTA@mail.gmail.com>
References: <20111130141827.GA3739@avtobot.cybertron>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davem@davemloft.net
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Jon Smirl <jonsmirl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:59687 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757124Ab1K3QNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 11:13:54 -0500
Received: by ggnr5 with SMTP id r5so765909ggn.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 08:13:53 -0800 (PST)
In-Reply-To: <20111130141827.GA3739@avtobot.cybertron>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello colleagues,

On Wed, Nov 30, 2011 at 6:18 PM, Alexander Smirnov
<alex.bluesman.smirnov@gmail.com> wrote:

[skipped]

> This stack has working implementation in 'linux-zigbee.sourceforge.net'
> project, but unfortunately all the development was freezed according to
> unknown issue and it hasn't been merged to mailnline.
>
> Currently I'm the one engineer who continue working on them. So the
> following patch series is based on the project mentioned above, and I just
> cut code into roudimentary pieces with minor fixes.

Alexander, thank you for continuing the work on the project! I'm glad to see
those patches being submitted to the mainline kernel.

> The code in the following patches was tested by 6LowPAN module. I took at230
> transciever driver from 'linux-zigbee' and brought up IPv6 network, it worked.
>
> Could please anyone review patches and let me know what do you think?

Several global notes:

1) Could you please include any (virtual or real) device driver
implementing the stack.
There was a "virtual radio" driver written for SoftMAC devices. The
driver had some small
design problems, but I think the stripped down version can be included
in the patchset.

2) Could you please rearrange the patches a little bit:
I'd really like to see the "monitor" devices interface pushed in the
first round of the patches.
It depends only on "simple mlme" and "RX/TX datapath" patches IIRC. It
would be really
good to merge those things first as it would then allow one to
implement their drivers,
check the radio, capture radio frames, etc.

I'll try reviewing patches really soon (as the time permits). However
could you please specify,
your changes over the last state I pushed to sf.net git repos (devel
or devel-30 branches)
to ease review?

-- 
With best wishes
Dmitry
