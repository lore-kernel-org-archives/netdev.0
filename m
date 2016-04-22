From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC PATCH v3 net-next 2/3] tcp: Handle eor bit when coalescing
 skb
Date: Thu, 21 Apr 2016 21:30:50 -0700
Message-ID: <20160422043034.GA95383@kafai-mba.local>
References: <1461133497-1515104-1-git-send-email-kafai@fb.com>
 <1461133497-1515104-3-git-send-email-kafai@fb.com>
 <CACSApvbyD7wFy+y2MrShKRMCTg-zF6UkP-Le867N=ssCYa-Yng@mail.gmail.com>
 <20160421165633.GA74969@kafai-mba.local>
 <CACSApvZO9d9B-5YOxm7LbpOvtORXQctTiocAY+2tigugDqr0eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Soheil Hassas Yeganeh <soheil@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:38756 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751039AbcDVEbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 00:31:01 -0400
Content-Disposition: inline
In-Reply-To: <CACSApvZO9d9B-5YOxm7LbpOvtORXQctTiocAY+2tigugDqr0eg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 21, 2016 at 05:14:37PM -0400, Soheil Hassas Yeganeh wrote:
> On another note, do you think putting this is a self-documenting
> helper function, say tcp_can_collapse_to(), would help readability?
Sure.  I will move unlikely(TCP_SKB_CB(to)->eor) to a new helper
function tcp_skb_can_collapse_to() in the next spin.
