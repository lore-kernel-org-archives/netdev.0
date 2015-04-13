From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH net-next v2 1/4] cxgb4/iw_cxgb4/cxgb4i: remove duplicate
 definitions
Date: Mon, 13 Apr 2015 10:38:08 -0600
Message-ID: <20150413163808.GA17521@obsidianresearch.com>
References: <cover.1428930614.git.varun@chelsio.com>
 <6358f849b5a1a3727879f4f2f5c855e3a5b95ab4.1428930614.git.varun@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-rdma@vger.kernel.org, davem@davemloft.net,
	JBottomley@parallels.com, roland@purestorage.com,
	leedom@chelsio.com, anish@chelsio.com, hariprasad@chelsio.com,
	swise@opengridcomputing.com, kxie@chelsio.com,
	praveenm@chelsio.com, kumaras@chelsio.com
To: Varun Prakash <varun@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:55227 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932119AbbDMQiO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 12:38:14 -0400
Content-Disposition: inline
In-Reply-To: <6358f849b5a1a3727879f4f2f5c855e3a5b95ab4.1428930614.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 13, 2015 at 07:34:23PM +0530, Varun Prakash wrote:
> define struct ulptx_idata in common header file t4_msg.h
> to remove duplicate definitions.

The Infiniband side of this patch looks OK.

Reviewed-By: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>

Just some random thoughts on the other patches:
 - Try and use 'if (IS_ENABLED(CONFIG_XX))' over #ifdef 
   to improve compile test coverage. This would drop a fair number
   of ifdefs.
 - Some of the commit message are short, or non existant (ie #4)
 - Generally, no need for 'static inline' in a .c file, the compiler knows
   what to do.

Regards,
Jason
