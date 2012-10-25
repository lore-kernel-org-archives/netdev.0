From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: switching network namespace midway
Date: Thu, 25 Oct 2012 09:15:34 -0700
Message-ID: <87a9var0ih.fsf@xmission.com>
References: <CAFaHj6FjDULMCdta3bhVu2mtJeR9TuJVMmbC0H6jjkfb6A5t-Q@mail.gmail.com>
	<878vavshhp.fsf@xmission.com> <20121024212116.GG15034@kvack.org>
	<CAFaHj6Ey4vzXskvsKB_dG4fKGsn4X5oCF3N0YpGskiSaXrGSOw@mail.gmail.com>
	<20121025155927.GI15034@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: rsa <ravi.mlists@gmail.com>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:49747 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946237Ab2JYQPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 12:15:44 -0400
In-Reply-To: <20121025155927.GI15034@kvack.org> (Benjamin LaHaise's message of
	"Thu, 25 Oct 2012 11:59:28 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise <bcrl@kvack.org> writes:

> On Thu, Oct 25, 2012 at 11:29:34AM -0400, rsa wrote:
>> Hi Ben
>> For L2TP that should work very well. But, with other tunnel types like GRE etc.
>> route lookups have to be done first in the inner and then outer.  It
>> makes it easier
>> to keep keep the tunnel in the inner namespace in such cases. right?
>
> I've read IPv4 gre code, and it appears to do the right thing on rx, but it 
> does *not* appear to handle namespaces correctly on transmit.  In general, 
> I would expect pretty much all code to get namespace handling correct for 
> the rx case.  I'll have a closer look at fixing this tomorrow if nobody else 
> beats me to it.

It will be interesting to see what you come up with. 

Eric
