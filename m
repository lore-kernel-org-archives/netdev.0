From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Low latency diagnostic tools
Date: Thu, 6 Aug 2009 10:19:53 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908061017001.5507@gentwo.org>
References: <alpine.DEB.1.10.0908051706050.30180@gentwo.org> <20090806094736.591b7086.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:54094 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752183AbZHFOUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 10:20:10 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 59C8382CEA8
	for <netdev@vger.kernel.org>; Thu,  6 Aug 2009 10:41:32 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MezquXZcGixq for <netdev@vger.kernel.org>;
	Thu,  6 Aug 2009 10:41:28 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id CDA1C82CEA7
	for <netdev@vger.kernel.org>; Thu,  6 Aug 2009 10:41:25 -0400 (EDT)
In-Reply-To: <20090806094736.591b7086.lk-netdev@lk-netdev.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Aug 2009, Mark Smith wrote:

> This implementation of One Way Active Measurement Protocol might be of
> interest:
>
> http://www.internet2.edu/performance/owamp/

It needs an accurate timesource. So it wont be of general use unless
everyone adopts ptp or so. Latencies today are way below 100 microseconds
which is not doable with the accuracy provided by ntp.

> Some of the performance tuning parts of the README below would also be
> useful in the Net area of the Linux Foundation wiki. Possibly the
> "Testing" section could be changed to "Testing and Measurement"
>
> http://www.linuxfoundation.org/en/Net:Main_Page

Ok. I will look at that.
