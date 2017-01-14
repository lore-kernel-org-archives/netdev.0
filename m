From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/13] tcp: RACK fast recovery
Date: Fri, 13 Jan 2017 23:19:42 -0500 (EST)
Message-ID: <20170113.231942.649931559969853825.davem@davemloft.net>
References: <20170113061142.127344-1-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ncardwell@google.com,
        nanditad@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35300 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750823AbdANETr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 23:19:47 -0500
In-Reply-To: <20170113061142.127344-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Thu, 12 Jan 2017 22:11:29 -0800

> The patch set enables RACK loss detection (draft-ietf-tcpm-rack-01)
> to trigger fast recovery with a reordering timer.
> 
> Previously RACK has been running in auxiliary mode where it is
> used to detect packet losses once the recovery has triggered by
> other algorithms (e.g., FACK). By inspecting packet timestamps,
> RACK can start ACK-driven repairs timely. A few similar heuristics
> are no longer needed and are either removed or disabled to reduce
> the complexity of the Linux TCP loss recovery engine:
> 
>   1. FACK (Forward Acknowledgement)
>   2. Early Retransmit (RFC5827)
>   3. thin_dupack (fast recovery on single DUPACK for thin-streams)
>   4. NCR (Non-Congestion Robustness RFC4653) (RFC4653)
>   5. Forward Retransmit
> 
> After this change, Linux's loss recovery algorithms consist of
>   1. Conventional DUPACK threshold approach (RFC6675)
>   2. RACK and Tail Loss Probe (draft-ietf-tcpm-rack-01)
>   3. RTO plus F-RTO extension (RFC5682)
> 
> The patch set has been tested on Google servers extensively and
> presented in several IETF meetings. The data suggests that RACK
> successfully improves recovery performance:
> https://www.ietf.org/proceedings/97/slides/slides-97-tcpm-draft-ietf-tcpm-rack-01.pdf
> https://www.ietf.org/proceedings/96/slides/slides-96-tcpm-3.pdf

Series applied, thanks for all of your hard work.
