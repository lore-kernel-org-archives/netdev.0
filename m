From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/2] veth: Configurable nterface MTU
Date: Fri, 27 Feb 2009 04:41:48 -0800
Message-ID: <m163iwf3w3.fsf@fess.ebiederm.org>
References: <m1ljrtkavi.fsf@fess.ebiederm.org>
	<m1fxi1kasv.fsf@fess.ebiederm.org>
	<20090227.024916.184944062.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56034 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbZB0MlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 07:41:16 -0500
In-Reply-To: <20090227.024916.184944062.davem@davemloft.net> (David Miller's message of "Fri\, 27 Feb 2009 02\:49\:16 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Wed, 25 Feb 2009 21:49:04 -0800
>
>> @@ -249,6 +253,19 @@ static int veth_close(struct net_device *dev)
>>  	return 0;
>>  }
>>  
>> +static int is_valid_veth_mtu(int new_mtu)
>> +{
>> +	return (new_mtu >= MIN_MTU && new_mtu <= MAX_MTU);
>> +}
>> +
>> +static int veth_change_mtu(struct net_device *dev, int new_mtu)
>> +{
>> +	if (is_valid_veth_mtu(new_mtu))
>> +		return -EINVAL;
>> +	dev->mtu = new_mtu;
>> +	return 0;
>> +}
>> +
>
> This validity test seems to be reversed?

Crap.  You are correct. I will respin.

Eric

