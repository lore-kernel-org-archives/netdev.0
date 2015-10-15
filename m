From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: [PATCH net-next v2] netlink: Rightsize IFLA_AF_SPEC size
 calculation
Date: Thu, 15 Oct 2015 05:52:40 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC350F7AD4DB@ORSMSX101.amr.corp.intel.com>
References: <1444802314-28830-1-git-send-email-ronen.arad@intel.com>
	<1444837888-32656-1-git-send-email-ronen.arad@intel.com>
 <20151014.192422.1272488031691006858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57102 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753384AbbJOFwm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 01:52:42 -0400
In-Reply-To: <20151014.192422.1272488031691006858.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Wednesday, October 14, 2015 7:24 PM
>To: Arad, Ronen
>Cc: netdev@vger.kernel.org
>Subject: Re: [PATCH net-next v2] netlink: Rightsize IFLA_AF_SPEC size
>calculation
>
>From: Ronen Arad <ronen.arad@intel.com>
>Date: Wed, 14 Oct 2015 08:51:28 -0700
>
>> @@ -900,7 +901,7 @@ static noinline size_t if_nlmsg_size(const struct
>net_device *dev,
>>  	       + rtnl_vfinfo_size(dev, ext_filter_mask) /* IFLA_VFINFO_LIST */
>>  	       + rtnl_port_size(dev, ext_filter_mask) /* IFLA_VF_PORTS +
>IFLA_PORT_SELF */
>>  	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
>> -	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
>> +		+ rtnl_link_get_af_size(dev, ext_filter_mask) /* IFLA_AF_SPEC */
>>  	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_PORT_ID */
>
>Please don't change the indentation on this line, keep it matching
>the indentation of all of the surrounding lines of this expression.
[@Ronen] Sure. V3 submitted. My editor didn't like the indentation of the
surrounding lines which are one less than two TAB spaces but consistency
is important. 
>
>Thanks.
