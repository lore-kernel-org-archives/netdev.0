From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] fix ACK processing after netlink_dump_start
Date: Tue, 23 Oct 2007 18:34:28 +0200
Message-ID: <20071023163428.GC8125@postel.suug.ch>
References: <20071023144023.GA15035@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dcbw@redhat.com, jfannin@gmail.com, davem@davemloft.net,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:55334 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751684AbXJWQeH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 12:34:07 -0400
Content-Disposition: inline
In-Reply-To: <20071023144023.GA15035@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Denis V. Lunev <den@openvz.org> 2007-10-23 18:40
> Revert to original netlink behavior. Do not reply with ACK if the
> netlink dump has bees successfully started.
> 
> libnl has been broken by the cd40b7d3983c708aabe3d3008ec64ffce56d33b0
> The following command reproduce the problem:
>    /nl-route-get 192.168.1.1
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

ACK. Thank you for taking care of this.
