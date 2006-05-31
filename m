From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 2/2] iWARP Core Changes.
Date: Wed, 31 May 2006 12:17:26 -0700
Message-ID: <adaodxeypfd.fsf@cisco.com>
References: <20060531182650.3308.81538.stgit@stevo-desktop>
	<20060531182654.3308.41372.stgit@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mshefty@ichips.intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2-in.cisco.com ([171.71.176.71]:4269 "EHLO
	sj-iport-2.cisco.com") by vger.kernel.org with ESMTP
	id S965105AbWEaTRa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 15:17:30 -0400
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <20060531182654.3308.41372.stgit@stevo-desktop> (Steve Wise's message of "Wed, 31 May 2006 13:26:55 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > +EXPORT_SYMBOL(copy_addr);

I think if you want to export this, it needs a less generic name
(something with an rdma_ prefix probably).  Otherwise it's going to
collide someday...
