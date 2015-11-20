From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net 2/2] net: ip6mr: fix static mfc/dev leaks on table destruction
Date: Fri, 20 Nov 2015 10:52:49 -0800
Message-ID: <CAHA+R7OyczeFw0LmdYzkpuEg+z2R91qxiRZuyrB=c+kwnHvEBg@mail.gmail.com>
References: <1448024060-20466-1-git-send-email-razor@blackwall.org>
	<1448024060-20466-3-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:36556 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161213AbbKTSwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 13:52:50 -0500
Received: by ykdr82 with SMTP id r82so174200792ykd.3
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 10:52:49 -0800 (PST)
In-Reply-To: <1448024060-20466-3-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2015 at 4:54 AM, Nikolay Aleksandrov
<razor@blackwall.org> wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
> Similar to ipv4, when destroying an mrt table the static mfc entries and
> the static devices are kept, which leads to devices that can never be
> destroyed (because of refcnt taken) and leaked memory. Make sure that
> everything is cleaned up on netns destruction.
>
> Fixes: 8229efdaef1e ("netns: ip6mr: enable namespace support in ipv6 multicast forwarding code")
> CC: Benjamin Thery <benjamin.thery@bull.net>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Reviewed-by: Cong Wang <cwang@twopensource.com>
