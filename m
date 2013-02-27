From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH 0/4] sctp: fix association hangs due to reassembly/ordering
 logic
Date: Wed, 27 Feb 2013 08:41:33 -0800
Message-ID: <512E373D.9020301@us.ibm.com>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com> <20130226.173758.1729388485427908984.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lee.roberts@hp.com, netdev@vger.kernel.org, vyasevich@gmail.com,
	nhorman@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:45734 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752286Ab3B0QmI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 11:42:08 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Wed, 27 Feb 2013 11:42:07 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 3F7366E8057
	for <netdev@vger.kernel.org>; Wed, 27 Feb 2013 11:41:56 -0500 (EST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1RGfvYu180428
	for <netdev@vger.kernel.org>; Wed, 27 Feb 2013 11:41:57 -0500
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1RGiGg4001941
	for <netdev@vger.kernel.org>; Wed, 27 Feb 2013 09:44:17 -0700
In-Reply-To: <20130226.173758.1729388485427908984.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/26/2013 2:37 PM, David Miller wrote:
> From: "Lee A. Roberts" <lee.roberts@hp.com>
> Date: Tue, 26 Feb 2013 07:36:12 -0700
>
>> This series of patches resolves several SCTP association hangs observed during
>> SCTP stress testing.  Observable symptoms include communications hangs with
>> data being held in the association reassembly and/or lobby (ordering) queues.
>> Close examination of reassembly/ordering queues may show either duplicated
>> or missing packets.
>>
>> Lee A. Roberts (4):
>>    sctp: fix association hangs due to off-by-one errors in
>>      sctp_tsnmap_grow()
>>    sctp: fix association hangs due to reneging packets below the
>>      cumulative TSN ACK point
>>    sctp: fix association hangs due to errors when reneging events from
>>      the ordering queue
>>    sctp: fix association hangs due to partial delivery errors
> Vlad, Sridhar, and Neil, please review.

I am no longer able to spend time on reviewing SCTP patches.
Please remove my name from the maintainers list. Should i submit a patch ?

Thanks
Sridhar
