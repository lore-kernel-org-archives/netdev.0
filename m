From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [iproute2] iproute2 question
Date: Thu, 18 Mar 2010 08:59:19 -0700
Message-ID: <20100318085919.05328127@nehalam>
References: <f4f837ab1003180202h6b2d5ed0ledd2a24dfd2627df@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: thomas yang <lampsu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55453 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999Ab0CRRTx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 13:19:53 -0400
In-Reply-To: <f4f837ab1003180202h6b2d5ed0ledd2a24dfd2627df@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Mar 2010 17:02:16 +0800
thomas yang <lampsu@gmail.com> wrote:

> Hi,
> 
> Linux router R (has some interfaces)  use the table "main" as default
> routing table to route packets.  If  some link connected to R failed,
> I want to use another table "backup_tbl" to route packets; if the
> broken link repaired , go back to use table "main"  .  How to do this?

That's now it works. Use a real routing daemon.

-- 
