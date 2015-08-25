From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH v3 net-next 7/8] geneve: Consolidate Geneve functionality
 in single module.
Date: Tue, 25 Aug 2015 13:55:04 -0700
Message-ID: <CALnjE+p7gd7c7CF4y9T7Xhs7gmekNDZX8uvRNunJJkPgcKsYgQ@mail.gmail.com>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
	<1440438195-5695-8-git-send-email-pshelar@nicira.com>
	<20150825181915.GG3707@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:38277 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753885AbbHYUzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 16:55:04 -0400
Received: by igfj19 with SMTP id j19so21425549igf.1
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 13:55:04 -0700 (PDT)
In-Reply-To: <20150825181915.GG3707@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2015 at 11:19 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 08/24/15 at 10:43am, Pravin B Shelar wrote:
>> -     if (ip_tunnel_collect_metadata() && geneve->collect_md) {
>> +     if (ip_tunnel_collect_metadata() || gs->collect_md) {
>
> OK, what I pointed out in patch 5 is fixed here.
>
right, I forgot to fix it in that patch.

> Metadata bits look good.
>
> Acked-by: Thomas Graf <tgraf@suug.ch>
