From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 04/13] netfilter: regard users as refcount for
 l4proto's per-net data
Date: Wed, 27 Jun 2012 11:05:05 +0200
Message-ID: <20120627090505.GA18372@1984>
References: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1340289410-17642-4-git-send-email-gaofeng@cn.fujitsu.com>
 <20120625112029.GB4607@1984>
 <4FE93375.1080803@cn.fujitsu.com>
 <20120626144708.GB11165@1984>
 <4FEA6309.5060305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39234 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754906Ab2F0JFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 05:05:13 -0400
Content-Disposition: inline
In-Reply-To: <4FEA6309.5060305@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 27, 2012 at 09:34:01AM +0800, Gao feng wrote:
[...]
> >>> I think that this change is similar to patch 1/1, I think you should
> >>> send it as a separated patch.
> >>>
> >>
> >> Yes, It looks better.
> >> should I change this and rebase whole patchset or
> >> maybe you just apply this patchset and then I send a cleanup patch to do this?
> > 
> > This patch includes changes that are not included in the description,
> > so you have two choices:
> > 
> > 1) You resend me this patch with appropriate description (including
> > the fact that you're fixing the same thing that patch 1/1 does). This
> > option still I don't like too much, since making two different things
> > in one single patch is nasty, but well if you push me...
> 
> Sorry, I don't know which the same thing I fixed in this patch and 1/13 patch.
> the 1/13 patch only change the proto's registration order. and this patch doesn't
> change the registration order.
> 
> This patch is used to try to make variable "users" clear.

Never mind, I'll take the patchset. Thanks Gao.
