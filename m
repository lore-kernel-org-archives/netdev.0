From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] vrf: rename the framework to mrf
Date: Mon, 24 Aug 2015 18:40:55 +0200
Message-ID: <55DB4917.1010307@6wind.com>
References: <1440259820-7875-1-git-send-email-nicolas.dichtel@6wind.com> <20150822.104721.739206355128347497.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	dsa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35586 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbbHXQk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 12:40:58 -0400
Received: by wicne3 with SMTP id ne3so77590843wic.0
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 09:40:57 -0700 (PDT)
In-Reply-To: <20150822.104721.739206355128347497.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/08/2015 19:47, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Sat, 22 Aug 2015 18:10:20 +0200
>
>> This patch renames the recently added vrf driver. 'VRF' term is very
>> generic and there is no clear definition of it.
>> For example, someone may expect more isolation and uses network name=
spaces
>> to implement VRF,
>
> This is a rediculous argument.
>
> Does someone using VRF on a Cisco box expect Linux namespaces to be u=
sed?
>
> Sorry, this is not going to get applied.
>
I spent some time today to check threads on this topic on Quagga and on=
 netdev
and I digged into the VRF-lite's commercial documentations. I finally a=
gree
with you, let's drop this patch.


Nicolas
