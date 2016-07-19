From: Shiraz Saleem <shiraz.saleem@intel.com>
Subject: Re: [PATCH V2] Add flow control to the portmapper
Date: Tue, 19 Jul 2016 09:50:24 -0500
Message-ID: <20160719145024.GA69464@ssaleem-MOBL4.amr.corp.intel.com>
References: <1468869810-64420-1-git-send-email-shiraz.saleem@intel.com>
 <20160719054006.GF20674@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
	swise@opengridcomputing.com, e1000-rdma@lists.sourceforge.net,
	netdev@vger.kernel.org, Mustafa Ismail <mustafa.ismail@intel.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:26174 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753627AbcGSOu1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2016 10:50:27 -0400
Content-Disposition: inline
In-Reply-To: <20160719054006.GF20674@leon.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2016 at 08:40:06AM +0300, Leon Romanovsky wrote:
> 
> You are the one user of this new inline function.
> Why don't you directly call to netlink_unicast() in your ibnl_unicast()
> without messing with widely visible header file?

Since there is a non-blocking version of nlmsg_unicast(), the idea is 
to make a blocking version available to others as well as maintain 
consistency of existing code.
