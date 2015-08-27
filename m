From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v5 net-next 7/8] geneve: Consolidate Geneve functionality
 in single module.
Date: Thu, 27 Aug 2015 09:31:23 -0700
Message-ID: <CAEP_g=-0tEjcg875MbjyxyM2PGh8U4hk6WWMR9NuTt2FC758cA@mail.gmail.com>
References: <1440658015-13028-1-git-send-email-pshelar@nicira.com> <1440658015-13028-8-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:35346 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068AbbH0Qbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 12:31:44 -0400
Received: by laaa3 with SMTP id a3so7120611laa.2
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 09:31:43 -0700 (PDT)
In-Reply-To: <1440658015-13028-8-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2015 at 11:46 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> geneve_core module handles send and receive functionality.
> This way OVS could use the Geneve API. Now with use of
> tunnel meatadata mode OVS can directly use Geneve netdevice.
> So there is no need for separate module for Geneve. Following
> patch consolidates Geneve protocol processing in single module.
>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Reviewed-by: Jesse Gross <jesse@nicira.com>
