From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] net/irda/ircomm_tty.c: Use flip buffers to deliver data
Date: Thu, 12 May 2011 12:17:51 +0100
Message-ID: <20110512121751.61d62446@lxorguk.ukuu.org.uk>
References: <1305198280-14449-1-git-send-email-amit.virdi@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <samuel@sortiz.org>, <alan@linux.intel.com>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <shiraz.hashim@st.com>,
	<armando.visconti@st.com>, <viresh.kumar@st.com>
To: Amit Virdi <amit.virdi@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:43449 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752607Ab1ELLRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 07:17:14 -0400
In-Reply-To: <1305198280-14449-1-git-send-email-amit.virdi@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 May 2011 16:34:40 +0530
Amit Virdi <amit.virdi@st.com> wrote:

> use tty_insert_flip_string and tty_flip_buffer_push to deliver incoming data
> packets from the IrDA device instead of delivering the packets directly to the
> line discipline. Following later approach resulted in warning "Sleeping function
> called from invalid context".
> 
> Signed-off-by: Amit Virdi <amit.virdi@st.com>

Acked-by: Alan Cox <alan@linux.intel.com>

