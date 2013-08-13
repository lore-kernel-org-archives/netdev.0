From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v5 1/5] bnx2x: protect different statistics flows
Date: Mon, 12 Aug 2013 21:24:02 -0700 (PDT)
Message-ID: <20130812.212402.138911128487906526.davem@davemloft.net>
References: <1376349903-3461-1-git-send-email-dmitry@broadcom.com>
	<1376349903-3461-2-git-send-email-dmitry@broadcom.com>
	<20130812171208.7dde2569@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com,
	ariele@broadcom.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379Ab3HMEYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 00:24:04 -0400
In-Reply-To: <20130812171208.7dde2569@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 12 Aug 2013 17:12:08 -0700

> On Tue, 13 Aug 2013 02:24:59 +0300
> "Dmitry Kravkov" <dmitry@broadcom.com> wrote:
> 
>> +	bool					stats_started;
>> +	struct semaphore			stats_sema;
> 
> Is there a reason to use a counting semaphore? Do you expect it to
> be held across user process boundary? or want count > 1?
> 
> Use of semaphores as a locking primitive is discouraged,
> instead us a mutex.

Would you please look at the feedback I gave these guys to the
previous iteration of these changes?

They were using custom locking primitives and semaphores gave
the best approximation to the semantics they were looking for.

Thanks.
