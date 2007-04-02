From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 10/10] forcedeth: work around NULL skb dereference crash
Date: Mon, 2 Apr 2007 21:10:14 +0200
Message-ID: <20070402191014.GC2081@elte.hu>
References: <20070402115325.GA945@elte.hu> <DBFABB80F7FD3143A911F9E6CFD477B0189CB20B@hqemmail02.nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org
To: Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:51424 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965709AbXDBTKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2007 15:10:32 -0400
Content-Disposition: inline
In-Reply-To: <DBFABB80F7FD3143A911F9E6CFD477B0189CB20B@hqemmail02.nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ayaz Abdulla <AAbdulla@nvidia.com> wrote:

> I had responded eariler to the thread asking you to try out the patch
> found in bug 8058:
> http://bugzilla.kernel.org/show_bug.cgi?id=8058
> 
> I believe that is the caush of the NULL skb dereference issue.

ah, sorry - i checked the wrong thread for your mail!

(btw., could you please bump the default for max_interrupt_work up from 
6 to at least 30? Bursts of 30 packets isnt hard to trigger, it happens 
commonly on my box - and 6 are trivial to trigger and the messages look 
quite alarming to the untrained eye and the condition also hurts 
performance. Thanks!)

	Ingo
