From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 0/6] tcp_metrics: Network namespace bloat reduction
Date: Mon, 09 Mar 2015 15:21:38 -0500
Message-ID: <87oao1yl9p.fsf@x220.int.ebiederm.org>
References: <87d25hrv9m.fsf@x220.int.ebiederm.org>
	<20150219.144929.1003473344851168804.davem@davemloft.net>
	<87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	<20150309.160929.681706454453258086.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: edumazet@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, hannes@stressinduktion.org,
	ddutt@cumulusnetworks.com, vipin@cumulusnetworks.com,
	shmulik.ladkani@gmail.com, dsahern@gmail.com
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:48346 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753534AbbCIUZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 16:25:17 -0400
In-Reply-To: <20150309.160929.681706454453258086.davem@redhat.com> (David
	Miller's message of "Mon, 09 Mar 2015 16:09:29 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@redhat.com> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Mon, 09 Mar 2015 13:22:52 -0500
>
>> This is a small pile of patches that convert tcp_metrics from using a
>> hash table per network namespace to using a single hash table for all
>> network namespaces.
>> 
>> This is broken up into several patches so that each small step along
>> the way could be carefully scrutinized as I wrote it, and equally so
>> that each small step can be reviewed.
>> 
>> There are two minor cleanups included.  The addition of a missing panic
>> when the tcp_metrics hash table can not be allocated during boot and the
>> removal of the return code from tcp_metrics_flush_all
>> 
>> The motivation for this change is that the tcp_metrics hash table at
>> 128KiB is the single largest component of a freshly allocated network
>> namespace.
>
> Looks like there is feedback for this series, so I'll let you address
> those and submit a V2.

Fair enough.


Eric
