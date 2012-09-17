From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v3 0/4] Take care of xfrm policy when checking
 dst entries
Date: Mon, 17 Sep 2012 21:52:20 +0200
Message-ID: <50577F74.9040200@6wind.com>
References: <1347350987-8054-1-git-send-email-nicolas.dichtel@6wind.com> <20120917.124953.1599275868994343219.davem@davemloft.net> <5057688B.3030509@gmail.com> <20120917.142504.115219640757684297.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vyasevich@gmail.com, eric.dumazet@gmail.com, sds@tycho.nsa.gov,
	james.l.morris@oracle.com, eparis@parisplace.org, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:62482 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754761Ab2IQTw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 15:52:27 -0400
Received: by eekc1 with SMTP id c1so3617129eek.19
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 12:52:25 -0700 (PDT)
In-Reply-To: <20120917.142504.115219640757684297.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/09/2012 20:25, David Miller a =E9crit :
> From: Vlad Yasevich <vyasevich@gmail.com>
> Date: Mon, 17 Sep 2012 14:14:35 -0400
>
>> I think he expected you to take Eric's patch that removed those
>> pieces.
>
> Eric's patch was a cleanup, so it went into 'net-next'.
>
> Nicolas's patch is a bonafide bug fix so needs to be
> targetted at 'net'
My fault, it was 'net-next'. I will rebase them against 'net'.

Should I post the last one (4/4) separately, against net-next? Because =
without=20
the '3/4', the cleanup is a bit larger and will cause a conflict during=
 the merge.
