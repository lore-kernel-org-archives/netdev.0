From: John Heffner <johnwheffner@gmail.com>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Wed, 11 Mar 2009 08:34:23 -0700
Message-ID: <1e41a3230903110834k7fd0e48clfb01e9ec5a189f1@mail.gmail.com>
References: <20090309200505.GA58375@bts.sk>
	 <20090309.170927.130334650.davem@davemloft.net>
	 <87bps8fkaw.fsf@basil.nowhere.org>
	 <20090311.063058.236235660.davem@davemloft.net>
	 <20090311150149.GG11935@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, md@bts.sk,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:17517 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148AbZCKPe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 11:34:27 -0400
Received: by qw-out-2122.google.com with SMTP id 5so57723qwi.37
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2009 08:34:24 -0700 (PDT)
In-Reply-To: <20090311150149.GG11935@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2009 at 8:01 AM, Andi Kleen <andi@firstfloor.org> wrote:
> On Wed, Mar 11, 2009 at 06:30:58AM -0700, David Miller wrote:
>> From: Andi Kleen <andi@firstfloor.org>
>> Date: Wed, 11 Mar 2009 11:03:35 +0100
>>
>> > Perhaps this points to the default buffer sizing heuristics to
>> > be too aggressive for >= 1GB?
>>
>> It's necessary Andi, you can't fill a connection on a trans-
>> continental connection without at least a 4MB receive buffer.
>
> Seems pretty arbitary to me. It's the value for a given bandwidth*latency
> product, but why not half or twice the bandwidth? I don't think
> that number is written in stone like you claim.

It is of course just a number, though not exactly arbitrary -- it's
approximately the required value for transcontinental 100 Mbps paths.
Choosing the value is a matter of engineering trade-offs, and seemed
like a reasonable cap at this time.

Any cap so much lower that it would give a small bound for LAN
latencies would bring us back to the bad old days where you couldn't
get anything more than 10 Mbps on the wide area.

  -John
