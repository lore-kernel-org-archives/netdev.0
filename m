From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 09 Sep 2008 16:36:49 +0200
Message-ID: <87zlmhs7we.fsf@basil.nowhere.org>
References: <48C59F75.6030504@redhat.com> <48C5A9A9.9040503@hp.com>
	<48C6052D.2080203@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>, Netdev <netdev@vger.kernel.org>
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:53956 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbYIIOgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 10:36:49 -0400
In-Reply-To: <48C6052D.2080203@redhat.com> (Chris Snook's message of "Tue, 09 Sep 2008 01:10:05 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Snook <csnook@redhat.com> writes:
>
> I'd like to know where the 40 ms magic number comes from. 

>From TCP_ATO_MIN

#define TCP_ATO_MIN     ((unsigned)(HZ/25))

> That's the
> one that really hurts, and if we could lower that without doing
> horrible things elsewhere in the stack, 

You can lower it (with likely some bad side effects), but I don't think it 
would make these apps very happy in the end because they likely want
no delay at all.

-Andi
