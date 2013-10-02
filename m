From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 1/2] sit: allow to use rtnl ops on fb tunnel
Date: Wed, 02 Oct 2013 09:36:02 +0200
Message-ID: <524BCCE2.8000700@6wind.com>
References: <524AB26B.1070700@6wind.com>	<1380643500-5018-1-git-send-email-nicolas.dichtel@6wind.com> <20131001.125923.700243113980583930.davem@davemloft.net> <524BC816.1000702@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	pshelar@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:34874 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752938Ab3JBHgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 03:36:05 -0400
Received: by mail-we0-f174.google.com with SMTP id q58so450209wes.5
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 00:36:03 -0700 (PDT)
In-Reply-To: <524BC816.1000702@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/10/2013 09:15, Nicolas Dichtel a =E9crit :
> Le 01/10/2013 18:59, David Miller a =E9crit :
>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Date: Tue,  1 Oct 2013 18:04:59 +0200
>>
>>> rtnl ops where introduced by ba3e3f50a0e5 ("sit: advertise tunnel p=
aram via
>>> rtnl"), but I forget to assign rtnl ops to fb tunnels.
>>>
>>> Now that it is done, we must remove the explicit call to
>>> unregister_netdevice_queue(), because  the fallback tunnel is added=
 to the queue
>>> in sit_destroy_tunnels() when checking rtnl_link_ops of all netdevi=
ces (this
>>> is valid since commit 5e6700b3bf98 ("sit: add support of x-netns"))=
=2E
>>>
>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>
>> Applied and queued up for -stable.
Another things about ipip: between 0974658da47c ("ipip: advertise tunne=
l param
via rtnl", v3.8) and fd58156e456d ("IPIP: Use ip-tunneling code.", v3.1=
0) the
fb device of ipip module has the same problem.
Should I send a patch?
