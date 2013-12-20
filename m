From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH net-next] ipv6: Not need to get address prefix
Date: Fri, 20 Dec 2013 15:36:03 +0800
Message-ID: <CAJFZqHwtXBw-w17XLw4VCUEj=1YG0J0tqod2Qr4-o91zJ_NaVw@mail.gmail.com>
References: <1387517994-11707-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f180.google.com ([209.85.128.180]:57974 "EHLO
	mail-ve0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754089Ab3LTHgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 02:36:05 -0500
Received: by mail-ve0-f180.google.com with SMTP id jz11so1235833veb.39
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 23:36:03 -0800 (PST)
In-Reply-To: <1387517994-11707-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 1:39 PM,  <roy.qing.li@gmail.com> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> +               rt = rt6_add_route_info(net, rinfo->prefix, rinfo->prefix_len,
> +                                       gwaddr, dev->ifindex, pref);

Sorry,  Please drop this patch,  if rinfo->prefix_len=0 and rinfo->length=1,
 rt6_add_route_info maybe broken.

-Roy
