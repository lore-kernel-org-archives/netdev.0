From: Jarno Rajahalme <jrajahalme@nicira.com>
Subject: Re: [RFC PATCH 3/5] netfilter: Allow calling into nat helper without skb_dst.
Date: Wed, 21 Oct 2015 13:44:34 -0700
Message-ID: <D79451E8-3017-43B6-A140-116AFA800524@nicira.com>
References: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com> <1445379629-112880-3-git-send-email-jrajahalme@nicira.com> <20151021104414.GB2135@salvia>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35362 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755421AbbJUUog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 16:44:36 -0400
Received: by pasz6 with SMTP id z6so64460622pas.2
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 13:44:35 -0700 (PDT)
In-Reply-To: <20151021104414.GB2135@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Oct 21, 2015, at 3:44 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> 
> On Tue, Oct 20, 2015 at 03:20:27PM -0700, Jarno Rajahalme wrote:
>> NAT checksum recalculation code assumed existence of skb_dst, which
>> becomes a problem for a later patch in the series.  Simplify this by
>> removing the checks, as the checksum will be dealt with later in the
>> stack.
> 
> Please, resubmit netfilter patches to netfilter-devel@vger.kernel.org

Will do.

  Jarno
