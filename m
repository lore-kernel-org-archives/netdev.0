From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V3 1/2] IB/ipoib: Add rtnl_link_ops support
Date: Wed, 29 Aug 2012 15:59:59 +0300
Message-ID: <503E124F.2050107@mellanox.com>
References: <1345724119-32110-1-git-send-email-ogerlitz@mellanox.com> <1345724119-32110-2-git-send-email-ogerlitz@mellanox.com> <Pine.GSO.4.63.1208291450330.1098@stinky-local.trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, Erez Shitrit <erezsh@mellanox.co.il>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:45544 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752567Ab2H2NAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 09:00:14 -0400
In-Reply-To: <Pine.GSO.4.63.1208291450330.1098@stinky-local.trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/08/2012 15:53, Patrick McHardy wrote:
> On Thu, 23 Aug 2012, Or Gerlitz wrote:
>
>> new file mode 100644
>> index 0000000..18d6ac9
>> --- /dev/null
>> +++ b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
>> ...
>> +
>> +enum {
>> +    IFLA_IPOIB_UNSPEC,
>> +    IFLA_IPOIB_CHILD_PKEY,
>> +    __IFLA_IPOIB_MAX
>> +};
>> +
>> +#define IFLA_IPOIB_MAX (__IFLA_IPOIB_MAX - 1)
>
> This should go into include/linux/if_link.h
>

sure, will fix
