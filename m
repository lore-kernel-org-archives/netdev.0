From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] net loopback: Set loopback_dev to NULL when freed
Date: Mon, 16 Sep 2013 18:52:27 -0700
Message-ID: <87k3igcizo.fsf@xmission.com>
References: <CA+HUmGih9akzhpRrb_0WEapi4jGcuSV8qO==QeRWHoqnxzFyng@mail.gmail.com>
	<87k3iggw8m.fsf_-_@xmission.com>
	<1379379051.4751.0.camel@edumazet-glaptop>
	<20130916.213435.1508866100258405440.davem@davemloft.net>
	<1379382102.4751.2.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	jiri@resnulli.us, alexander.h.duyck@intel.com, amwang@redhat.com,
	netdev@vger.kernel.org, fruggeri@aristanetworks.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:38770 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793Ab3IQBwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 21:52:37 -0400
In-Reply-To: <1379382102.4751.2.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Mon, 16 Sep 2013 18:41:42 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Mon, 2013-09-16 at 21:34 -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Mon, 16 Sep 2013 17:50:51 -0700
>> 
>> > On Mon, 2013-09-16 at 16:52 -0700, Eric W. Biederman wrote:
>> >> It has recently turned up that we have a number of long standing bugs
>> >> in the network stack cleanup code with use of the loopback device
>> >> after it has been freed that have not turned up because in most cases
>> >> the storage allocated to the loopback device is not reused, when those
>> >> accesses happen.
>> >> 
>> >> Set looback_dev to NULL to trigger oopses instead of silent data corrupt
>> >> when we hit this class of bug.
>> >> 
>> >> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> >> ---
>> > 
>> > Acked-by: Eric Dumazet <edumazet@google.com>
>> 
>> I'd like to apply this to 'net', any objections?
>
> No objections from me.

No objects from me I just hadn't seen it as a bug fix, but I guess it
sort of is.

Eric
