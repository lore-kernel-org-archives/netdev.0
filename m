From: Gal Pressman <galp@mellanox.com>
Subject: Re: [RFC PATCH net-next 1/3] ethtool: Add link down reason callback
Date: Thu, 22 Jun 2017 13:33:16 +0300
Message-ID: <b6a2be2f-3bcc-128c-35fb-1ae00940b462@mellanox.com>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
 <1498050286-17141-2-git-send-email-galp@mellanox.com>
 <20170621084317.45879939@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com
To: Stephen Hemminger <stephen@networkplumber.org>,
        Gal Pressman <galp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr00042.outbound.protection.outlook.com ([40.107.0.42]:54654
        "EHLO EUR02-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752719AbdFVKda (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 06:33:30 -0400
In-Reply-To: <20170621084317.45879939@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> +	ETHTOOL_LINK_PWR_BUDGET_EXC, /* Power budget exceeded */
>> +	ETHTOOL_LINK_MODULE_ADMIN_DOWN, /* Module admin down */
>> +
>> +	ETHTOOL_LINK_REASONS_COUNT
>> +};
> Any enumerated list is going to get changed too often.
> Could the API just return a string?

The motivation for the enumerated list is to make this API as generic as possible and compatible
with all ethernet drivers.

Returning a string is a good idea, maybe change the vendor specific opcode to a string?
