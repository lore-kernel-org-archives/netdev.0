From: Roland Dreier <rdreier@cisco.com>
Subject: Re: cxgb4: Make unnecessarily global functions static
Date: Wed, 21 Apr 2010 12:03:05 -0700
Message-ID: <adaljcgpr12.fsf@roland-alpha.cisco.com>
References: <adapr1spr7e.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:46804 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122Ab0DUTDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 15:03:09 -0400
In-Reply-To: <adapr1spr7e.fsf@roland-alpha.cisco.com> (Roland Dreier's message
	of "Wed, 21 Apr 2010 11:59:17 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By the way, this results in the following improvement in size in my
x86-64 build, so it's not just source cleanup:

add/remove: 0/4 grow/shrink: 3/6 up/down: 186/-346 (-160)
function                                     old     new   delta
static.T                                   18293   18412    +119
t4_ethrx_handler                             649     698     +49
handle_trace_pkt                             127     145     +18
t4_wr_mbox_meat                              728     722      -6
t4_read_rss                                  147     140      -7
t4_mc_read                                   201     187     -14
sf1_write                                    243     228     -15
sf1_read                                     279     262     -17
t4_edc_read                                  240     222     -18
t4_pktgl_free                                 41       -     -41
t4_read_indirect                              46       -     -46
t4_write_indirect                             52       -     -52
t4_wait_op_done_val                          130       -    -130
-- 
Roland Dreier <rolandd@cisco.com> || For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
