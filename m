From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 06/10] ixgbe: eliminate Smatch warnings in
 ixgbe_debugfs.c
Date: Wed, 21 Nov 2012 12:04:20 -0500 (EST)
Message-ID: <20121121.120420.741100079474597575.davem@davemloft.net>
References: <1353494856-12344-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1353494856-12344-7-git-send-email-jeffrey.t.kirsher@intel.com>
	<20121121110409.GG6186@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, joshua.a.hay@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53475 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821Ab2KUREW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 12:04:22 -0500
In-Reply-To: <20121121110409.GG6186@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 21 Nov 2012 14:04:09 +0300

> On Wed, Nov 21, 2012 at 02:47:32AM -0800, Jeff Kirsher wrote:
>> +	len = simple_write_to_buffer(ixgbe_dbg_reg_ops_buf,
>> +				     sizeof(ixgbe_dbg_reg_ops_buf)-1,
>> +				     ppos,
>> +				     buffer,
>> +				     count);
>> +	if (len < 0)
>> +		return -EFAULT;
> 
> Any negative return is bad.
> 
> 	if (len)
> 		return len;
 ...
>> @@ -187,15 +196,15 @@ static ssize_t ixgbe_dbg_netdev_ops_write(struct file *filp,
 ...
>> +	if (len < 0)
>> +		return -EFAULT;
> 
> Same.

Agreed.
