From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: undo spurious timeout after SACK reneging
Date: Sun, 24 Mar 2013 17:28:21 -0400 (EDT)
Message-ID: <20130324.172821.1575298454791235977.davem@davemloft.net>
References: <1364157745-24866-1-git-send-email-ycheng@google.com>
	<CADVnQy=koYif1cM+VuXirz26jV33zDK2KHNW=EQUfRaGqBHa+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, edumazet@google.com, nanditad@google.com,
	netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44011 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754814Ab3CXV2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 17:28:22 -0400
In-Reply-To: <CADVnQy=koYif1cM+VuXirz26jV33zDK2KHNW=EQUfRaGqBHa+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sun, 24 Mar 2013 16:50:41 -0400

> On Sun, Mar 24, 2013 at 4:42 PM, Yuchung Cheng <ycheng@google.com> wrote:
>> On SACK reneging the sender immediately retransmits and forces a
>> timeout but disables Eifel (undo). If the (buggy) receiver does not
>> drop any packet this can trigger a false slow-start retransmit storm
>> driven by the ACKs of the original packets. This can be detected with
>> undo and TCP timestamps.
>>
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
>> ---
>>  net/ipv4/tcp_input.c | 7 ++-----
>>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied.
