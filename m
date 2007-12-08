From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 2/3]sysctl: prepare core tables to point to
 netns variables
Date: Sat, 08 Dec 2007 00:12:05 -0800 (PST)
Message-ID: <20071208.001205.166185340.davem@davemloft.net>
References: <47594659.2050505@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45060
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755499AbXLHIMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 03:12:07 -0500
In-Reply-To: <47594659.2050505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 07 Dec 2007 16:10:49 +0300

> Some of ctl variables are going to be on the struct 
> net. Here's the way to adjust the ->data pointer on the
> ctl_table-s to point on the right variable.
> 
> Since some pointers still point on the global variables,
> I keep turning the write bits off on such tables.
> 
> This looks to become a common procedure for net sysctls,
> so later parts of this code may migrate to some more
> generic place.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, but please see if you can find a more pretty way to
do this, thanks.
