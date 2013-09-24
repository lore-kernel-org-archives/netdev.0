From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v4 net-next 06/27] bonding: modify
 bond_get_slave_by_dev() to use neighbours
Date: Tue, 24 Sep 2013 21:39:08 +0200
Message-ID: <20130924193908.GA7561@redhat.com>
References: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
 <1380023227-9576-7-git-send-email-vfalico@redhat.com>
 <20130924.151943.1884204173373827600.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, jiri@resnulli.us, fubar@us.ibm.com,
	andy@greyhouse.net
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61551 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750774Ab3IXTlB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 15:41:01 -0400
Content-Disposition: inline
In-Reply-To: <20130924.151943.1884204173373827600.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 03:19:43PM -0400, David Miller wrote:
>From: Veaceslav Falico <vfalico@redhat.com>
>Date: Tue, 24 Sep 2013 13:46:46 +0200
>
>> -	return NULL;
>> +	return (struct slave *)netdev_lower_dev_get_private(bond->dev,
>> +							    slave_dev);
>>  }
>
>void pointers never need to be cast, please remove this "struct slave *"
>cast.

Yep, leftover from the sandbox versions, will change and submit the new
version. Sorry about that :-/.
