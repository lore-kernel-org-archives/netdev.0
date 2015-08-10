From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v4 3/4] openvswitch: Use regular GRE net_device
 instead of vport
Date: Sun, 9 Aug 2015 20:49:36 -0700
Message-ID: <CALnjE+oFUPv44Ln20_h+jdd73U4Lm1gym8H-tEmFXyKA5QnTig@mail.gmail.com>
References: <1438830760-6572-1-git-send-email-pshelar@nicira.com>
	<20150809161924.GF3113@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>, Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:38677 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbbHJDth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2015 23:49:37 -0400
Received: by igfj19 with SMTP id j19so42126198igf.1
        for <netdev@vger.kernel.org>; Sun, 09 Aug 2015 20:49:36 -0700 (PDT)
In-Reply-To: <20150809161924.GF3113@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for reviews, I sent out patches with the Kconfig fix.

On Sun, Aug 9, 2015 at 9:19 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 08/05/15 at 08:12pm, Pravin B Shelar wrote:
>> Using flow based tunneling, we can implement
>> OVS GRE vport. This patch removes all of the OVS
>> specific GRE code and make OVS use a ip_gre net_device.
>> Minimal GRE vport is kept to handle compatibility with
>> current userspace application.
>>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>
> After the dependency fix:
> Acked-by: Thomas Graf <tgraf@suug.ch>
