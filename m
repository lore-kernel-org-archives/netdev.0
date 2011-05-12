From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/irda/ircomm_tty.c: Use flip buffers to deliver data
Date: Thu, 12 May 2011 18:03:03 -0400 (EDT)
Message-ID: <20110512.180303.182109841640606265.davem@davemloft.net>
References: <1305198280-14449-1-git-send-email-amit.virdi@st.com>
	<20110512121751.61d62446@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit.virdi@st.com, samuel@sortiz.org, alan@linux.intel.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, shiraz.hashim@st.com,
	armando.visconti@st.com, viresh.kumar@st.com
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48878 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758736Ab1ELWFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 18:05:00 -0400
In-Reply-To: <20110512121751.61d62446@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Thu, 12 May 2011 12:17:51 +0100

> On Thu, 12 May 2011 16:34:40 +0530
> Amit Virdi <amit.virdi@st.com> wrote:
> 
>> use tty_insert_flip_string and tty_flip_buffer_push to deliver incoming data
>> packets from the IrDA device instead of delivering the packets directly to the
>> line discipline. Following later approach resulted in warning "Sleeping function
>> called from invalid context".
>> 
>> Signed-off-by: Amit Virdi <amit.virdi@st.com>
> 
> Acked-by: Alan Cox <alan@linux.intel.com>

Applied to net-next-2.6, thanks.
