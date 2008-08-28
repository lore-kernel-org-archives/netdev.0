From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/3] IPROUTE: generate compat messages that match nla_parse_nested_compat
Date: Thu, 28 Aug 2008 11:51:31 +0200
Message-ID: <20080828095131.GX20815@postel.suug.ch>
References: <20080828011340.7987.74684.stgit@jtkirshe-mobile.jf.intel.com> <20080828011347.7987.24759.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, davem@davemloft.net,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56804 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751675AbYH1JvL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 05:51:11 -0400
Content-Disposition: inline
In-Reply-To: <20080828011347.7987.24759.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Jeff Kirsher <jeffrey.t.kirsher@intel.com> 2008-08-27 18:13
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch updates libnetlink.c to generate nested compat netlink
> attributes in the same format that is parsed by the kernels 2.6.26
> and newer.
> 
> This patch will fix the prio multiqueue option for 2.6.26 kernels,
> but will break compatibility with all kernels prior to 2.6.26.

I'm not sure what you mean by fix, I can't find any nested attributes
being parsed in the proposed sch_multiq.c.

Wouldn't it be simpler to have q_multiq.c use addattr_nest() instead of
addattr_nest_compat() instead of changing addattr_nest_compat() to be
equivalent to addattr_nest()?
