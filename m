From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 1/2] ipv4: move local_port_range out of CONFIG_SYSCTL
Date: Thu, 8 May 2014 22:17:46 -0700
Message-ID: <CAM_iQpUGvKegVSUtg4uD9F08TEqrSYOgdhCrp_XFq9DYc=-8=A@mail.gmail.com>
References: <1399399370-7849-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140507.172641.1968628089443229607.davem@davemloft.net>
	<20140507224848.GA1272@electric-eye.fr.zoreil.com>
	<20140508.225221.188940173991264163.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:44709 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246AbaEIFRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 01:17:47 -0400
Received: by mail-ob0-f181.google.com with SMTP id wm4so4139974obc.26
        for <netdev@vger.kernel.org>; Thu, 08 May 2014 22:17:46 -0700 (PDT)
In-Reply-To: <20140508.225221.188940173991264163.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 8, 2014 at 7:52 PM, David Miller <davem@davemloft.net> wrote:
> From: Francois Romieu <romieu@fr.zoreil.com>
> Date: Thu, 8 May 2014 00:48:48 +0200
>
>> David Miller <davem@davemloft.net> :
>> [...]
>>> I think these two changes fix fairly serious issues that have existed for some
>>> time, so it should go into 'net', do you agree?
>>
>> Patch #1, yes.
>>
>> Without patch #2, the root group id is always granted ping init when
>> CONFIG_SYSCTL is not set. It's more cautious than serious.
>
> Still, initializing such fundamental values to different defaults
> based upon whether SYSCTL is enabled or not is pretty bad, so I've
> decided to apply both patches to 'net'.
>

Makes sense for me. Thanks, everyone!
