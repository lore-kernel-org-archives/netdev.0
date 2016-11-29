From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v5] iproute2: macvlan: add "source" mode
Date: Tue, 29 Nov 2016 12:42:27 -0800
Message-ID: <20161129124227.45bb69db@samsung9>
References: <1479812353-32400-1-git-send-email-michael-dev@fami-braun.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, projekt-wlan@fem.tu-ilmenau.de,
        steweg@gmail.com
To: Michael Braun <michael-dev@fami-braun.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35675 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751063AbcK2UvG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 15:51:06 -0500
Received: by mail-pf0-f172.google.com with SMTP id i88so33788449pfk.2
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 12:51:05 -0800 (PST)
In-Reply-To: <1479812353-32400-1-git-send-email-michael-dev@fami-braun.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Nov 2016 11:59:13 +0100
Michael Braun <michael-dev@fami-braun.de> wrote:

> Adjusting iproute2 utility to support new macvlan link type mode called
> "source".
> 
> Example of commands that can be applied:
>   ip link add link eth0 name macvlan0 type macvlan mode source
>   ip link set link dev macvlan0 type macvlan macaddr add 00:11:11:11:11:11
>   ip link set link dev macvlan0 type macvlan macaddr del 00:11:11:11:11:11
>   ip link set link dev macvlan0 type macvlan macaddr flush
>   ip -details link show dev macvlan0
> 
> Based on previous work of Stefan Gula <steweg@gmail.com>
> 
> Signed-off-by: Michael Braun <michael-dev@fami-braun.de>

Applied, and queued for next push
