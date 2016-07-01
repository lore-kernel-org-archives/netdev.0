From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net-next 10/42] mlxsw: spectrum_router: Add basic ipv4
 router initialization
Date: Fri, 1 Jul 2016 20:58:51 +0300
Message-ID: <20160701175851.GA11348@colbert.idosch.org>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
 <1467381910-3445-11-git-send-email-jiri@resnulli.us>
 <15542d5f-e11e-4901-0e36-8231012e8f7e@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jiri Pirko <jiri@resnulli.us>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <yotamg@mellanox.com>, <eladr@mellanox.com>,
	<nogahf@mellanox.com>, <ogerlitz@mellanox.com>,
	<sfeldma@gmail.com>, <roopa@cumulusnetworks.com>,
	<andy@greyhouse.net>, <tgraf@suug.ch>, <jhs@mojatatu.com>,
	<linville@tuxdriver.com>, <ivecera@redhat.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0067.outbound.protection.outlook.com ([104.47.2.67]:38296
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751604AbcGAWe5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2016 18:34:57 -0400
Content-Disposition: inline
In-Reply-To: <15542d5f-e11e-4901-0e36-8231012e8f7e@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jul 01, 2016 at 05:39:01PM IDT, dsa@cumulusnetworks.com wrote:
>On 7/1/16 8:04 AM, Jiri Pirko wrote:
>> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
>> index 05d5fcc..c2ac037 100644
>> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
>> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
>> @@ -74,6 +74,8 @@
>>
>>  #define MLXSW_SP_CELL_FACTOR 2	/* 2 * cell_size / (IPG + cell_size + 1) */
>>
>> +#define MLXSW_SP_RIF_MAX 800
>
>At most 800 RIFs can be created?

Yes.

Do you have use cases that require more than that? If so, how many
router interfaces would be required? That would be a good feedback for
us.

>Why 800?

Currently, trying to configure a RIF with an higher index will result in
firmware errors. We plan to increase this number in the future (don't
expect it to be infinite...).

We are currently implementing a new mechanism in the driver that will
query these resources from the firmware, so we won't need to hardcode
them.
