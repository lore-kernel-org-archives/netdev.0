From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] net: add support for linkdown sysctl to netconf
Date: Tue, 07 Jul 2015 09:57:57 +0200
Message-ID: <559B8685.4020509@6wind.com>
References: <1436206919-973-1-git-send-email-gospo@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Andy Gospodarek <gospo@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37827 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755417AbbGGH6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 03:58:00 -0400
Received: by wiclp1 with SMTP id lp1so42215505wic.0
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2015 00:57:59 -0700 (PDT)
In-Reply-To: <1436206919-973-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/07/2015 20:21, Andy Gospodarek a =C3=A9crit :
> This kernel patch exports the value of the new
> ignore_routes_with_linkdown via netconf.
>
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> Suggested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
You need also to patch devinet_conf_proc() so that a netlink message is
sent when the user updates the sysctl entry.


Regards,
Nicolas
