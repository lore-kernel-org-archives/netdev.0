From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Multicast packet loss
Date: Fri, 27 Feb 2009 14:45:27 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0902271441220.9381@qirst.com>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <alpine.DEB.1.10.0902271340320.9381@qirst.com> <49A8375A.6000006@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Kenny Chang <kchang@athenacr.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:42387 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755400AbZB0Tyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 14:54:32 -0500
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C666A82C597
	for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 14:59:27 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id DKtppbNKChYB for <netdev@vger.kernel.org>;
	Fri, 27 Feb 2009 14:59:27 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7D22C82C99E
	for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 14:59:23 -0500 (EST)
In-Reply-To: <49A8375A.6000006@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Feb 2009, Eric Dumazet wrote:

> Christoph Lameter a ?crit :
> > On Fri, 30 Jan 2009, Eric Dumazet wrote:
> >> 2.6.29-rc contains UDP receive improvements (lockless)
> >> Problem is multicast handling was not yet updated, but could be :)
> > When will that happen?
> When proven necessary :)
>
> Kenny problem is about scheduling storm. The extra spin_lock() in UDP
> multicast receive is not a problem.

My tests here show that 2.6.29-rc5 still looses ~5usec vs. 2.6.22 via
UDP. This would fix a regression.....

