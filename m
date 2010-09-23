From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 2/2 -next] r8169: use device model DMA API
Date: Thu, 23 Sep 2010 17:23:37 +0200
Message-ID: <20100923172337.3ad78757@dhcp-lab-109.englab.brq.redhat.com>
References: <1285243291-4520-1-git-send-email-sgruszka@redhat.com>
	<1285243291-4520-2-git-send-email-sgruszka@redhat.com>
	<AANLkTin-GPjkpp3gmS=1u5wxmxFMy_B6GL1MuDR79fDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Denis Kirjanov <kirjanov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60917 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755200Ab0IWPYO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Sep 2010 11:24:14 -0400
In-Reply-To: <AANLkTin-GPjkpp3gmS=1u5wxmxFMy_B6GL1MuDR79fDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Sep 2010 18:59:10 +0400
Denis Kirjanov <kirjanov@gmail.com> wrote:

> On Thu, Sep 23, 2010 at 4:01 PM, Stanislaw Gruszka <sgruszka@redhat.com> wrote:
> > Use DMA API as PCI equivalents will be deprecated. This change also
> > allow to allocate with GFP_KERNEL where possible.
> >
> > Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> > ---
> 
> dma_map_single and friend can fail. Thus, we should check for a return value.
> Yes, this is not directly related to current patch, but it would be
> great to fix this.

Sure, I will another patch with fix soon.

Stanislaw
