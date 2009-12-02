From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/3] Add new (iptables 1.4.5 compatible) tc/ipt/xt
 module.
Date: Wed, 2 Dec 2009 08:58:41 -0800
Message-ID: <20091202085841.1c37f49f@nehalam>
References: <cover.1259765732.git.andreas@fatal.se>
	<59840ae567f82d81e66367eddea56553e0771e5f.1259765732.git.andreas@fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53264 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754611AbZLBQ6r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2009 11:58:47 -0500
In-Reply-To: <59840ae567f82d81e66367eddea56553e0771e5f.1259765732.git.andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Dec 2009 16:11:50 +0100
Andreas Henriksson <andreas@fatal.se> wrote:

> Add a new cleaned up m_xt.c based on m_xt_old.c
> The new m_xt.c has been updated to use the new names and new api
> that xtables exposes in iptables 1.4.5.
> All the old internal api cruft has also been dropped.
> 
> Additionally, a configure script test is added to check for
> the new xtables api and set the TC_CONFIG_XT flag in Config.
> (tc/Makefile already handles this flag in previous commit.)
> 
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>

Will this still build on older versions?  The iproute source is supposed
to build even with really old kernels and older iptables. It has
maintained source and binary compatibility.

-- 
