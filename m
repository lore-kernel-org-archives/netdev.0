From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net v2] ipv4: fix wildcard search with inet_confirm_addr()
Date: Thu, 14 Nov 2013 11:32:53 +0100
Message-ID: <5284A6D5.7000804@6wind.com>
References: <alpine.LFD.2.03.1311082258430.1811@ssi.bg> <1384356209-4193-1-git-send-email-nicolas.dichtel@6wind.com> <alpine.LFD.2.03.1311132244001.1712@ssi.bg>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:56687 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274Ab3KNKcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 05:32:55 -0500
Received: by mail-wi0-f178.google.com with SMTP id hn6so2214380wib.11
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 02:32:55 -0800 (PST)
In-Reply-To: <alpine.LFD.2.03.1311132244001.1712@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/11/2013 22:27, Julian Anastasov a =E9crit :
>
> 	Hello,
>
> On Wed, 13 Nov 2013, Nicolas Dichtel wrote:
>
>> Help of this function says: "in_dev: only on this interface, 0=3Dany=
 interface",
>> but since commit 39a6d0630012 ("[NETNS]: Process inet_confirm_addr i=
n the
>> correct namespace."), the code supposes that it will never be NULL. =
This
>> function is never called with in_dev =3D=3D NULL, but it's exported =
and may be used
>> by an external module.
>>
>> Because this patch restore the ability to call inet_confirm_addr() w=
ith in_dev
>> =3D=3D NULL, I partially revert the above commit, as suggested by Ju=
lian.
>>
>> CC: Julian Anastasov <ja@ssi.bg>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> 	This patch looks ok to me, thanks!
>
> Reviewed-by: Julian Anastasov <ja@ssi.bg>
>
> 	Still, I think this is a net-next material
> and you have to wait some days... The net tree that
Ok.

> you are using is missing the changes that remove
> 'extern', so I think you have to port it to net-next
> tree to avoid the conflict in include/linux/inetdevice.h.
Yes, checkpatch already warns about this extern kerword.

Thank you,
Nicolas
