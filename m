From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Subject: Re: [PATCH 07/23] usb-gadget/f_loopback: use per-attribute show and
 store methods
Date: Mon, 28 Sep 2015 15:52:46 +0200
Message-ID: <5609462E.9060308@samsung.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-8-git-send-email-hch@lst.de> <560928B1.1000605@samsung.com>
 <20150928134101.GD30453@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Felipe Balbi <balbi@ti.com>, Tejun Heo <tj@kernel.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.w1.samsung.com ([210.118.77.11]:52106 "EHLO
	mailout1.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933933AbbI1Nwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 09:52:50 -0400
In-reply-to: <20150928134101.GD30453@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

W dniu 28.09.2015 o 15:41, Christoph Hellwig pisze:
> On Mon, Sep 28, 2015 at 01:46:57PM +0200, Andrzej Pietrasiewicz wrote:
>>>    }
>>>
>>> -static struct f_lb_opts_attribute f_lb_opts_qlen =
>>> -	__CONFIGFS_ATTR(qlen, S_IRUGO | S_IWUSR,
>>> -			f_lb_opts_qlen_show,
>>> -			f_lb_opts_qlen_store);
>>> -
>> In my opinion the below line belongs here:
>>
>> +CONFIGFS_ATTR(f_lb_opts_, qlen);
>
> The idea is to keep all the attribute defintions near the attribute
> array, similar to how most drivers define their sysfs attributes.
>

You were not consistent with the approach, though: with some
patches CONFIGFS_ATTR() are where __CONFIGFS_ATTR were,
with some other they are grouped.

> If you really don't like that way I'll move it back.

I think the change is more explicit/readable if the macro invocations
are where what they substitute used to be.

AP
