From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 07/13] QLogic VNIC: Handling configurable parameters of the driver
Date: Tue, 13 May 2008 13:41:37 -0700
Message-ID: <adabq3aj5ry.fsf@cisco.com>
References: <20080430171028.31725.86190.stgit@localhost.localdomain>
	<20080430171925.31725.22023.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	amar.mudrankit@qlogic.com, poornima.kamath@qlogic.com
To: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:28004 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755752AbYEMUlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 16:41:39 -0400
In-Reply-To: <20080430171925.31725.22023.stgit@localhost.localdomain>
	(Ramachandra K.'s message of "Wed, 30 Apr 2008 22:49:25 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > +	ib_get_cached_gid(config->ibdev, config->port, 0,
 > +			  &config->path_info.path.sgid);

Again, looks like a sleepable context so please use ib_query_gid()
instead.
