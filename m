From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 6/6] [TCP]: Reorganize struct tcp_sock to save 16 bytes
	on 64-bit arch
Date: Thu, 31 Jan 2008 18:33:40 -0200
Message-ID: <20080131203340.GG11940@ghostprotocols.net>
References: <1201804304-28777-1-git-send-email-acme@redhat.com> <1201804304-28777-2-git-send-email-acme@redhat.com> <1201804304-28777-3-git-send-email-acme@redhat.com> <1201804304-28777-4-git-send-email-acme@redhat.com> <1201804304-28777-5-git-send-email-acme@redhat.com> <1201804304-28777-6-git-send-email-acme@redhat.com> <1201804304-28777-7-git-send-email-acme@redhat.com> <47A22841.6090508@cosmosbay.com> <20080131201720.GE11940@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Eric Dumazet <dada1@cosmosbay.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49525 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760490AbYAaUeL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 15:34:11 -0500
Content-Disposition: inline
In-Reply-To: <20080131201720.GE11940@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Jan 31, 2008 at 06:17:20PM -0200, Arnaldo Carvalho de Melo escreveu:
> Em Thu, Jan 31, 2008 at 08:57:53PM +0100, Eric Dumazet escreveu:
> > Hum... retrans_out should sit close to packets_out (or lost_out/sacked_out 
> > ???), please.
> >
> > 'struct tcp_sock' is very large on 64 bits, so I would prefer to make sure 
> > most paths dont need to touch all 24 cache lines (or 25 cache lines).
> 
> That is perfectly fine, I'll replace my patch with another, that states
> this beyond doubt.

David, I just removed this patch from my net-2.6 tree, if you are ok
with the others, please pull.

- Arnaldo
