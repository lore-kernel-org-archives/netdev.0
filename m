From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Fix key serialization.
Date: Thu, 12 Feb 2015 11:02:07 -0800
Message-ID: <CANr6G5yyTRwwvgzB-eZE0-7UDP_P31+RQvYe0oWZh=prTStSMw@mail.gmail.com>
References: <1423763928-1554-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:36101 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751324AbbBLTC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 14:02:29 -0500
Received: by mail-wi0-f182.google.com with SMTP id l15so6075767wiw.3
        for <netdev@vger.kernel.org>; Thu, 12 Feb 2015 11:02:28 -0800 (PST)
In-Reply-To: <1423763928-1554-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12 February 2015 at 09:58, Pravin B Shelar <pshelar@nicira.com> wrote:
> Fix typo where mask is used rather than key.
>
> Fixes: 74ed7ab9264("openvswitch: Add support for unique flow IDs.")
> Reported-by: Joe Stringer <joestringer@nicira.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---

Thanks for looking into this. So in general we zero-initialize the
key, but not the mask---then use the key to determine which parts of
the key (or mask) to serialize?

This fixes the problem I was seeing.

Acked-by: Joe Stringer <joestringer@nicira.com>
