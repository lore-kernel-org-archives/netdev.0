From: David Miller <davem@davemloft.net>
Subject: Re: qlcnic binary sysfs file abuse
Date: Thu, 25 Jul 2013 14:09:33 -0700 (PDT)
Message-ID: <20130725.140933.1460349218585474906.davem@davemloft.net>
References: <20130707002949.GA15822@kroah.com>
	<0EA5B226BC5C7B45A71BF612AA8A019E355A3BD4@AVMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, rajesh.borundia@qlogic.com,
	shahed.shaikh@qlogic.com, jitendra.kalsaria@qlogic.com,
	Linux-Driver@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49675 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754781Ab3GYVJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 17:09:35 -0400
In-Reply-To: <0EA5B226BC5C7B45A71BF612AA8A019E355A3BD4@AVMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>
Date: Thu, 25 Jul 2013 19:37:46 +0000

>> -----Original Message-----
>> From: Greg KH [mailto:gregkh@linuxfoundation.org]
>> Sent: Saturday, July 06, 2013 5:30 PM
>> To: Rajesh Borundia; Shahed Shaikh; Jitendra Kalsaria; Sony Chacko; Dept-Eng
>> Linux Driver
>> Cc: netdev; linux-kernel
>> Subject: qlcnic binary sysfs file abuse
>> 
>> I was doing a kernel-wide audit on all of the binary sysfs files, and noticed a
>> metric ton of them in the qlcnic driver.
>> 
>> So, any objection to me just deleting these entirely?  Or, if they really are
>> needed, can I just move them to debugfs, which is where I think they should
>> have been from the beginning?
> 
> Some applications are using these files, please move them to debugfs.

This is quite a mess, and I've complained about all of the crazy
files created by qlcnic in the past.

debugfs is for things that do not create a ABI which the kernel has to
maintain forever.
