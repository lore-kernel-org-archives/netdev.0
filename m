From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1 0/3] mlx5 driver fixes for 4.5-rc2
Date: Sun, 07 Feb 2016 13:44:40 -0500 (EST)
Message-ID: <20160207.134440.449917136946691623.davem@davemloft.net>
References: <1454426781-7128-1-git-send-email-ogerlitz@mellanox.com>
	<56B76660.4050105@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, saeedm@mellanox.com, matanb@mellanox.com,
	eranbe@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754186AbcBGSor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 13:44:47 -0500
In-Reply-To: <56B76660.4050105@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun, 7 Feb 2016 17:44:32 +0200

> On 2/2/2016 5:26 PM, Or Gerlitz wrote:
>> We added here a patch from Matan and Alaa for addressing Linus
>> comments on
>> the mess w.r.t reserved field names in the driver/firmware
>> auto-generated file.
>>
>> Once the patch hits linus tree, we'll ask Doug to rebase his tree on
>> that
>> rc so both net-next and rdma-next development for 4.6 will be done
>> under
>> the fixed robust form.
> 
> Hi Dave,
> 
> We've identified few places in the auto generated file where the
> naming conversion
> of reserved fields was not fully applied. Since the patch only did
> re-naming of
> reserved fields which are not used for existing functionality, the
> testing we did
> under the modified header file didn't catch that...
> 
> We'll respin the patch and series.

Ok.
