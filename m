From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC PATCH net-next] qfq: handle the case that front slot is
 empty
Date: Sun, 28 Oct 2012 20:45:00 +0800
Message-ID: <1351428300.15482.2.camel@cr0>
References: <20121026165115.GA16947@paolo-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Fabio Checconi <fchecconi@gmail.com>
To: Paolo Valente <paolo.valente@unimore.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24919 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751551Ab2J1MpP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Oct 2012 08:45:15 -0400
In-Reply-To: <20121026165115.GA16947@paolo-ThinkPad-W520>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-26 at 18:51 +0200, Paolo Valente wrote:
> Here is a possible patch. Could you please give me a feedback?
> 
> If this patch actually works, there are some issues related to it that I would
> like to point out after your (and/or anyone else's) tests.

With this patch applied, I can't reproduce the crash any more.

And the following messages appear in the log:

[  430.956400] qfq: increasing class max_pkt_size from 1514 to 26130
[  430.981887] qfq: increasing class max_pkt_size from 26130 to 31922
[  431.011844] qfq: increasing class max_pkt_size from 1514 to 2962
[  431.060129] qfq: increasing class max_pkt_size from 31922 to 46402
[  431.096241] qfq: increasing class max_pkt_size from 2962 to 4410
[  431.123689] qfq: increasing class max_pkt_size from 4410 to 18890
[  431.134624] qfq: increasing class max_pkt_size from 18890 to 20338
[  431.149573] qfq: increasing class max_pkt_size from 20338 to 39162
[  431.328157] qfq: increasing class max_pkt_size from 46402 to 56538
[  431.339731] qfq: increasing class max_pkt_size from 56538 to 65226
[  431.363699] qfq: increasing class max_pkt_size from 39162 to 44954
[  431.376303] qfq: increasing class max_pkt_size from 44954 to 46402
[  431.482082] qfq: increasing class max_pkt_size from 46402 to 62330
[  431.520339] qfq: increasing class max_pkt_size from 62330 to 65226
