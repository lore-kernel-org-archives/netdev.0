From: Jason Wang <jasowang@redhat.com>
Subject: Re: tun mq failure
Date: Wed, 23 Jan 2013 21:20:41 +0800
Message-ID: <50FFE3A9.5070003@redhat.com>
References: <20130123100516.GB8108@redhat.com> <20130123110640.GC7005@order.stressinduktion.org> <50FFD2A7.6010402@redhat.com> <20130123131845.GB18276@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65106 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754370Ab3AWNiw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 08:38:52 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r0NDcqrK022256
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 08:38:52 -0500
In-Reply-To: <20130123131845.GB18276@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2013 09:18 PM, Michael S. Tsirkin wrote:
> On Wed, Jan 23, 2013 at 08:08:07PM +0800, Jason Wang wrote:
>> On 01/23/2013 07:06 PM, Hannes Frederic Sowa wrote:
>>> On Wed, Jan 23, 2013 at 12:05:16PM +0200, Michael S. Tsirkin wrote:
>>>> This is when trying to start a VPN using some old openvpn binary so MQ
>>>> is not set.
>>>>
>>>> So
>>>> 1. I think we should limit allocation of MQ to when MQ flag is set in SETIFF.
>>>> 2. order 7 allocation is 2^^7 pages - about half a megabyte of contigious
>>>>    memory. This is quite likely to fail.
>>>>    Let's start with a small limit on number of queues, like 8?
>>>>    Then we know it will succeed.
>>>>    Longer term we might want to solve it differently.
>>> This has been come up before:
>>> http://thread.gmane.org/gmane.linux.network/255647/focus=255902
>>>
>>> I think a solution to this problem is still outstanding.
>>>
>> I draft a patch in the reply of in that thread, but didn't get feedback
>> from reporter.
> Yes it's essentialy same.
> So can you please submit an official patch with proper
> subject commit log and signature?

Ok, will post the patch soon.
