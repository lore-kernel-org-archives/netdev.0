From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: possible bridge regression in "bridge: implement
 [add/del]_slave ops"?
Date: Thu, 30 Jun 2011 10:08:19 -0700
Message-ID: <20110630100819.0e4b536f@nehalam.ftrdhcpuser.net>
References: <201106301033.23997.alexander.stein@systec-electronic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Alexander Stein <alexander.stein@systec-electronic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49277 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752360Ab1F3RI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 13:08:27 -0400
In-Reply-To: <201106301033.23997.alexander.stein@systec-electronic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 Jun 2011 10:33:23 +0200
Alexander Stein <alexander.stein@systec-electronic.com> wrote:

> * echo $(pgrep rstpd) > /var/run/rstpd.pid
> * brctl addbr br1
> * echo 1 > /sys/class/net/br1/bridge/stp_state

This bogus. You are running both kernel and spanning
tree daemon at the same time!

Doing the echo of 1 to stp_state forces kernel spanning
tree. You want 2 which is what is supposed to be use for user
mode spanning tree.

Note: dropping LKML off the thread to save time/space/noise.
