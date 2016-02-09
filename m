From: "Fastabend, John R" <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 7/7] net: ixgbe: add support for tc_u32 offload
Date: Tue, 9 Feb 2016 03:30:58 -0800
Message-ID: <56B9CDF2.2050908@gmail.com>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
 <20160203092959.1356.91778.stgit@john-Precision-Tower-5810>
 <20160203100716.GA20905@office.Home> <56B1D5D2.7040807@gmail.com>
 <56B1F689.5040609@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, jiri@resnulli.us,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>, "Amir Vadai\"" <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:36330 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932929AbcBILbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 06:31:14 -0500
Received: by mail-ob0-f182.google.com with SMTP id ba1so183147244obb.3
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 03:31:14 -0800 (PST)
In-Reply-To: <56B1F689.5040609@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>>
>> If you leave ht and order off the tc cli I believe 'tc' just
>> picks some semi-arbitrary ones for you. I've been in the habit
>> of always specifying them even for software filters.
>>
> 
> The default table id is essentially 0x800. Default bucket is 0.
> "order" essentially is the filter id. And given you can link tables
> (Nice work John!); essentially the ht:bucket:nodeid is an "address" to
> a specific filter on a specific table and when makes sense a specific
> hash bucket. Some other way to look at it is as a way to construct
> a mapping to a TCAM key.
> What John is doing is essentially taking the nodeid and trying to use
> it as a priority. In otherwise the abstraction is reduced to a linked
> list in which the ordering is how the list is traversed.
> It may work in this case, but i am for being able to explicitly specify
> priorities.

Sorry bombing you with emails Jamal. Another thing to note is ixgbe
doesn't support hash tables explicitly but our other devices do. So
when a hash node is created we can map that onto a hardware block
and actually do the hash.

> 
> cheers,
> jamal
> 
