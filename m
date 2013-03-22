From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2] libnetlink: check flag NLM_F_DUMP_INTR during
 dumps
Date: Fri, 22 Mar 2013 16:03:19 +0100
Message-ID: <514C72B7.8070804@6wind.com>
References: <1363963557-3888-1-git-send-email-nicolas.dichtel@6wind.com> <1363964393.4431.66.camel@edumazet-glaptop>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:36397 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932192Ab3CVPDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 11:03:22 -0400
Received: by mail-wi0-f175.google.com with SMTP id c10so2593007wiw.2
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 08:03:21 -0700 (PDT)
In-Reply-To: <1363964393.4431.66.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/03/2013 15:59, Eric Dumazet a =C3=A9crit :
> On Fri, 2013-03-22 at 15:45 +0100, Nicolas Dichtel wrote:
>> When this flag is set, it means that dump was interrupted and result=
 may be
>> wrong. Ask user to restart.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
>
> Do we have a guarantee this will complete eventually, on some hosts
> constantly adding removing entries ?
>

No. You mean it will be better to just print a warning and continue the=
 dump?
