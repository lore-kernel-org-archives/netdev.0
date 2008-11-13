From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] remove an unnecessary field in struct tcp_skb_cb
Date: Thu, 13 Nov 2008 20:57:53 +0100
Message-ID: <87fxlvcsam.fsf@basil.nowhere.org>
References: <1226571707.18006.23.camel@nathan.suse.cz>
	<491C6DA6.8030200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Petr Tesarik <ptesarik@suse.cz>, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Saikiran Madugula <hummerbliss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:58544 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbYKMT5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 14:57:55 -0500
In-Reply-To: <491C6DA6.8030200@gmail.com> (Saikiran Madugula's message of "Thu, 13 Nov 2008 18:10:46 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Saikiran Madugula <hummerbliss@gmail.com> writes:

> Petr Tesarik wrote:
>> The urg_ptr field is not used anywhere and is merely confusing.
>> 
> grep -r "urg_ptr" on my linux tree says otherwise.

I think you're confusing it with tcphdr's field of the same name.
Petr's patch is correct as far as I can see.

-Andi
-- 
ak@linux.intel.com
