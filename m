From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] sctp: proc: protect bind_addr->address_list accesses
 with rcu_read_lock()
Date: Thu, 6 Dec 2012 18:28:40 +0000
Message-ID: <20121206182840.GD16122@casper.infradead.org>
References: <a803093c70e857e8e01e554288ee79f66f7acda4.1354814846.git.tgraf@suug.ch>
 <50C0E300.3000703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:43550 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946537Ab2LFS2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 13:28:43 -0500
Content-Disposition: inline
In-Reply-To: <50C0E300.3000703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/12 at 01:25pm, Vlad Yasevich wrote:
> May want to avoid printing addresses that are !addr->valid.
> 
> Otherwise looks good.

Good point, I'll send a follow-up patch if that is OK. Same
applies to dead transports obviously.
