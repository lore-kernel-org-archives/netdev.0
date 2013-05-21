From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v3] sock_diag: notify packet socket creation/deletion
Date: Tue, 21 May 2013 17:14:50 +0200
Message-ID: <519B8F6A.7010406@6wind.com>
References: <1366818756-4234-5-git-send-email-nicolas.dichtel@6wind.com> <1368800738-4364-1-git-send-email-nicolas.dichtel@6wind.com> <20130519.232925.1972249319855411715.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:48954 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575Ab3EUPOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 11:14:53 -0400
Received: by mail-wg0-f49.google.com with SMTP id y10so418329wgg.4
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 08:14:52 -0700 (PDT)
In-Reply-To: <20130519.232925.1972249319855411715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/05/2013 08:29, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Fri, 17 May 2013 16:25:38 +0200
>
>> With this patch, a netlink message is sent each time a packet socket
>> is created or deleted.  The framework is generic, so it's easy to
>> add the notification for other kind of sockets.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> Just curious what you want to use this for.
Some HW (custom FPGA, ASICs, NPUs) are able to offload packet captures,=
 so it is=20
required to notify them.
