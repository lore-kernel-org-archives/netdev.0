From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net 2/3] openvswitch: Treat IP_CT_RELATED as new
Date: Thu, 15 Oct 2015 11:09:53 -0700
Message-ID: <CALnjE+qdTJHVMhLag-gYNFP=7CFkLuWYESedt2Pm8m3m3zwvyw@mail.gmail.com>
References: <1444846249-52053-1-git-send-email-joestringer@nicira.com>
	<1444846249-52053-3-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:35431 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752984AbbJOSJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 14:09:54 -0400
Received: by igbkq10 with SMTP id kq10so726549igb.0
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 11:09:53 -0700 (PDT)
In-Reply-To: <1444846249-52053-3-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2015 at 11:10 AM, Joe Stringer <joestringer@nicira.com> wrote:
> New, related connections are marked as such as part of ovs_ct_lookup(),
> but they are not marked as "new" if the commit flag is used. Make this
> consistent by treating IP_CT_RELATED as new as well.
>
> Reported-by: Jarno Rajahalme <jrajahalme@nicira.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Looks good.

Acked-by: Pravin B Shelar <pshelar@nicira.com>
