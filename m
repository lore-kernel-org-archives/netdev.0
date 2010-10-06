From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: [net-next-2.6 PATCH 2/3] bonding: add Speed/Duplex information
 to /proc/net/bonding/bond
Date: Wed, 06 Oct 2010 23:32:10 +0200
Message-ID: <4CACEADA.70009@ans.pl>
References: <4ca4b878.KGc4gLtXHLSFlAdV%ole@ans.pl> <20101006.142424.246555203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:34949 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752510Ab0JFVc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 17:32:27 -0400
In-Reply-To: <20101006.142424.246555203.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-10-06 23:24, David Miller wrote:
> From: Krzysztof Piotr Oledzki <ole@ans.pl>
> Date: Thu, 30 Sep 2010 18:19:04 +0200
>
>> Subject: bonding: add Speed/Duplex information to /proc/net/bonding/=
bond*
>>
>> Effect:
>>   Slave Interface: eth5
>>   MII Status: up
>>   Speed: 10000 Mbps
>>   Duplex: full
>>   Link Failure Count: 0
>>   Permanent HW addr: XX:XX:XX:XX:XX:XX
>>   Slave queue ID: 0
>>
>> Signed-off-by: Krzysztof Piotr Oledzki <ole@ans.pl>
>
> Changing the layout of a procfs file is pretty much always unsafe.
>
> Some useland program somewhere depends upon the current layout, and
> therefore very likely could break if we change the contents.
>
> We really can't apply a patch like this.  A most portable and
> extensible interface (netlink, ethtool) should be used to provide thi=
s
> information to userspace.

Sure, no problem.

Please note however that this procfs file was recently changed ("Slave=20
queue ID" was added) so if this is indeed a problem than we would=20
already heard about this.

Best regards,

			Krzysztof Ol=C4=99dzki
