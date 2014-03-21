From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 1/3] rtnetlink: fix fdb notification flags
Date: Fri, 21 Mar 2014 10:18:36 +0100
Message-ID: <532C03EC.1060902@6wind.com>
References: <1395247671-9356-1-git-send-email-nicolas.dichtel@6wind.com> <20140320.162503.536482270990113339.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:64768 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008AbaCUJSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 05:18:39 -0400
Received: by mail-we0-f175.google.com with SMTP id q58so1372731wes.20
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 02:18:38 -0700 (PDT)
In-Reply-To: <20140320.162503.536482270990113339.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/03/2014 21:25, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Wed, 19 Mar 2014 17:47:49 +0100
>
>> Commit 3ff661c38c84 ("net: rtnetlink notify events for FDB NTF_SELF =
adds and
>> deletes") reuses the function nlmsg_populate_fdb_fill() to notify fd=
b events.
>> But this function was used only for dump and thus was always setting=
 the
>> flag NLM_F_MULTI, which is wrong in case of a single notification.
>>
>> Libraries like libnl will wait forever for NLMSG_DONE.
>>
>> CC: Thomas Graf <tgraf@suug.ch>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> Applied.
>
David, do you plan to queue this serie in stable branch?
Applications using libnl may be stuck with this bug.


Thank you,
Nicolas
