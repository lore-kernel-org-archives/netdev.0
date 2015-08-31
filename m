From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] ip-tunnel: Use API to access tunnel metadata options.
Date: Mon, 31 Aug 2015 12:11:25 -0700
Message-ID: <CAEP_g=_LCrnqHzOgAhTSmrUPxBDGGCOCcgB_QnC44v8WSnoj6Q@mail.gmail.com>
References: <1440983378-2107-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:34427 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbbHaTLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 15:11:46 -0400
Received: by lbbtg9 with SMTP id tg9so66218139lbb.1
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 12:11:45 -0700 (PDT)
In-Reply-To: <1440983378-2107-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 30, 2015 at 6:09 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Currently tun-info options pointer is used in few cases to
> pass options around. But tunnel options can be accessed using
> ip_tunnel_info_opts() API without using the pointer. Following
> patch removes the redundant pointer and consistently make use
> of API.
>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Reviewed-by: Jesse Gross <jesse@nicira.com>
