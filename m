From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] qlcnic: using too much stack
Date: Tue, 10 Aug 2010 00:01:21 -0700 (PDT)
Message-ID: <20100810.000121.48516818.davem@davemloft.net>
References: <1281405801.1954.65.camel@Joe-Laptop.home>
	<D084A42E-7F2A-44F7-9273-DDD9214CB877@qlogic.com>
	<1281411546.1954.102.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anirban.chakraborty@qlogic.com, error27@gmail.com,
	amit.salecha@qlogic.com, Linux-Driver@qlogic.com,
	sucheta.chakraborty@qlogic.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38307
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752748Ab0HJHBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 03:01:02 -0400
In-Reply-To: <1281411546.1954.102.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 09 Aug 2010 20:39:06 -0700

> On Mon, 2010-08-09 at 20:31 -0700, Anirban Chakraborty wrote:
>> On Aug 10, 2010, at 7:33 AM, Joe Perches wrote:
>> > On Mon, 2010-08-09 at 18:43 -0700, Anirban Chakraborty wrote:
>> >> Your patch is fine except that the preferred way is to use kzalloc over kaclloc. kzalloc does not need that extra
>> >> argument that you are passing to kcalloc.
>> > You probably meant to write "my preferred way"
>> > as the kcalloc to "kzalloc with a multiply"
>> > ratio is pretty high.
>> I was suggesting based on the following:
>> http://lwn.net/Articles/147014/
> 
> Note that article suggests kzalloc for allocating
> a single zeroed object.
> 
> kcalloc is used for multiple zeroed objects and
> protects against oversized allocations.

Agreed, kcalloc should be used here.
