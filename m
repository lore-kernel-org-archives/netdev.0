From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] fib_trie: memory waste solutions
Date: Mon, 07 Apr 2008 09:58:04 +0200
Message-ID: <87bq4mrt9v.fsf@basil.nowhere.org>
References: <20080401172702.094c0700@extreme> <47F33D42.9080302@cosmosbay.com>
	<47F39998.8040605@cosmosbay.com> <20080402110335.66b04181@extreme>
	<47F3E031.1030806@cosmosbay.com> <20080404090257.2ec38b0c@extreme>
	<18425.50538.876583.892728@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out03.alice-dsl.net ([88.44.63.5]:5919 "EHLO
	smtp-out03.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106AbYDGINW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 04:13:22 -0400
In-Reply-To: <18425.50538.876583.892728@robur.slu.se> (Robert Olsson's message of "Mon, 7 Apr 2008 08:55:38 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Olsson <Robert.Olsson@data.slu.se> writes:
>
>  Do we get slower with vmalloc due to TLB-lookups etc? Guess this
>  should be investigated.

In some cases it might even go faster because a lot of x86 CPUs
have far more 4K TLBs than 2M TLBs. vmalloc is just quite expensive
in setup/free time, but that shouldn't be a big issue here.

The memory savings are impressive.

-Andi

