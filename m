From: Tom Herbert <therbert@google.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Fri, 25 Feb 2011 11:51:13 -0800
Message-ID: <AANLkTinNost8Swh2fhQh8UXVdPTW_bToS7LXmyuwqNNQ@mail.gmail.com>
References: <AANLkTimDtaV=WhZUUEivg3_vEUeUk3_WQSs09h7USiUj@mail.gmail.com>
	<AANLkTi=j9VdTZjw4iTsczv2eHjTXo59-fNneBMo8rJyp@mail.gmail.com>
	<20110225125644.GA9763@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Thomas Graf <tgraf@infradead.org>
To: Tom Herbert <therbert@google.com>,
	Bill Sommerfeld <wsommerfeld@google.com>,
	Daniel Baluta <daniel.baluta@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:51867 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932644Ab1BYTvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 14:51:17 -0500
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p1PJpGTO018212
	for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 11:51:16 -0800
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by hpaq2.eem.corp.google.com with ESMTP id p1PJpDmL008653
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 11:51:15 -0800
Received: by pvg7 with SMTP id 7so281367pvg.9
        for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 11:51:13 -0800 (PST)
In-Reply-To: <20110225125644.GA9763@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Using your SO_REUSEPORT patch and a modified bind using it. The same
> system is able to deliver ~650K queries per seconds while maxing out
> all cores completely.
>
Nice data point.

> Tom, Bill: do you have a timeline for merging this? Especially the
> UDP bits?
>
Bill has been working on the TCP implementation which is requiring
some fairly major surgery on the listener connections in syn-rcvd
state, this is ongoing.

On the UDP side, I believe the patch is functional, but as Eric
pointed out it probably could be further optimized.  I'll split out
the UDP bits into a separate patch and post that...

Tom

> -Thomas
>
