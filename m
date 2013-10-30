From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: named network namespace -- setns() with Invalid argument (errno 22)
Date: Wed, 30 Oct 2013 13:54:55 -0700
Message-ID: <87wqku7a3k.fsf@xmission.com>
References: <1383092184.12859.78.camel@dilip-laptop>
	<8738njfkdp.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: dilip.daya@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42768 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491Ab3J3UzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 16:55:05 -0400
In-Reply-To: <8738njfkdp.fsf@xmission.com> (Eric W. Biederman's message of
	"Tue, 29 Oct 2013 21:33:22 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ebiederm@xmission.com (Eric W. Biederman) writes:

> Dilip Daya <dilip.daya@hp.com> writes:
>
>> Hi All,
>>
>> Is the following intended behavior for adding "nested" named network namespaces ?
>
> Not exactly intended but this is not misbehavior either.
>
> Mostly this is a don't do that then scenario.

Let me clarify a little. The primary purpose of ip netns exec is to
allow programs that are not aware or more than one network namespace
to work without modification.  It is not intended to be a primary
environment for applications to run in.

Which is a big part of where the don't do that then, comes from.

If you can figure out what is going on and send patches I will be happy
to accept them.

Also public conversation is appreciated so that anyone else with the
same confusions may be educated at the same time.


Eric
