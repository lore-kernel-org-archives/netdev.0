From: Pavel Emelianov <xemul@openvz.org>
Subject: Re: [PATCH 2/2] Virtual ethernet device driver
Date: Thu, 12 Jul 2007 18:01:59 +0400
Message-ID: <46963457.1000306@openvz.org>
References: <4695F0BF.1000305@openvz.org> <4695F214.6020401@openvz.org> <469631F5.7080207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:4373 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761426AbXGLOCJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 10:02:09 -0400
In-Reply-To: <469631F5.7080207@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Pavel Emelianov wrote:
>> +	if (data != NULL && data[VETH_INFO_PEER] != NULL) {
>> +		err = nla_parse_nested(tb, IFLA_INFO_MAX,
>> +				data[VETH_INFO_PEER], ifla_policy);
>> +		if (err < 0)
>> +			return err;
>> +	}
> 
> 
> One more suggestion regarding the PEER attribute: you only nest
> IFLA attributes below it, but some information that might be
> interesting to use on device creation is contained in ifinfomsg
> (flags and ifindex). So I think it would be better to use a
> complete message, including header.

I don't get it. Can you elaborate, please.

Pavel
