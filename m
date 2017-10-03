From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/10] Introduce SCTP Stream Schedulers
Date: Tue, 03 Oct 2017 16:27:50 -0700 (PDT)
Message-ID: <20171003.162750.1603032130390868428.davem@davemloft.net>
References: <cover.1507069005.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        nhorman@tuxdriver.com, vyasevich@gmail.com, lucien.xin@gmail.com,
        David.Laight@ACULAB.COM
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55848 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751315AbdJCX1v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 19:27:51 -0400
In-Reply-To: <cover.1507069005.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Tue,  3 Oct 2017 19:20:07 -0300

> This patchset introduces the SCTP Stream Schedulers are defined by
> https://tools.ietf.org/html/draft-ietf-tsvwg-sctp-ndata-13
> 
> It provides 3 schedulers at the moment: FCFS, Priority and Round Robin.
> The other 3, Round Robin per packet, Fair Capacity and Weighted Fair
> Capacity will be added later. More specifically, WFQ is required by
> WebRTC Datachannels.
> 
> The draft also defines the idata chunk, allowing a usermsg to be
> interrupted by another piece of idata from another stream. This patchset
> *doesn't* include it. It will be posted later by Xin Long.  Its
> integration with this patchset is very simple and it basically only
> requires a tweak in sctp_sched_dequeue_done(), to ignore datamsg
> boundaries.
> 
> The first 5 patches are a preparation for the next ones. The most
> relevant patches are the 4th and 6th ones. More details are available on
> each patch.
> 
> v2: changelog update on patch 3

This doesn't look too scary :-)

Series applied, thanks!
