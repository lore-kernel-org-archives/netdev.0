From: Divy Le Ray <divy@chelsio.com>
Subject: Re: cxgb3: Replace LRO with GRO
Date: Sun, 18 Jan 2009 12:33:42 -0800
Message-ID: <49739226.3020104@chelsio.com>
References: <20090115235803.GA9000@gondor.apana.org.au> <49704015.6020503@chelsio.com> <20090116085645.GA14678@gondor.apana.org.au> <49706B87.7080806@chelsio.com> <20090117050839.GA24215@gondor.apana.org.au> <4971BCDE.50600@chelsio.com> <20090117130827.GA17896@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:9836 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640AbZARUe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 15:34:59 -0500
In-Reply-To: <20090117130827.GA17896@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sat, Jan 17, 2009 at 03:11:26AM -0800, Divy Le Ray wrote:
>> Yes.
> 
> Great.  Please give this patch a whirl.
> 

Hi Herbert,

Thanks for the patch. It does improve the performance.
I'm now getting about 5.3Gbs.

Here is a oprofile output:
      33.929900  copy_user_generic_unrolled          vmlinux
       7.150300  process_responses                  cxgb3.ko
       6.261100  refill_fl                          cxgb3.ko
       6.181700  memcpy                              vmlinux
       6.168100  inet_gro_receive                    vmlinux
       4.593700  put_page                            vmlinux
       4.085600  dev_gro_receive                     vmlinux
       3.833800  tcp_gro_receive                     vmlinux
       1.817100  free_hot_cold_page                  vmlinux
       1.715000  skb_copy_datagram_iovec             vmlinux
       1.705900  skb_gro_header                      vmlinux
       1.676400  get_page_from_freelist              vmlinux
       1.256700  tcp_recvmsg                         vmlinux
       0.893800  get_pageblock_flags_group           vmlinux
       0.850700  irq_entries_start                   vmlinux
       0.803000  _raw_spin_lock                      vmlinux
       0.782600  skb_gro_receive                     vmlinux
       0.739500  memcpy_toiovec                      vmlinux
       0.725900  napi_fraginfo_skb                   vmlinux
       0.601200  kfree                               vmlinux

Cheers,
Divy
