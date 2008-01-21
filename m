From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/7] bonding: 7 fixes for 2.6.24
Date: Sun, 20 Jan 2008 17:36:44 -0800
Message-ID: <20080120173644.4586483e.akpm@linux-foundation.org>
References: <12006159033257-git-send-email-fubar@us.ibm.com>
	<20080120.171538.12566715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org, jgarzik@pobox.com,
	andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43050 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756706AbYAUBhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 20:37:16 -0500
In-Reply-To: <20080120.171538.12566715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 20 Jan 2008 17:15:38 -0800 (PST) David Miller <davem@davemloft.net> wrote:

> From: Jay Vosburgh <fubar@us.ibm.com>
> Date: Thu, 17 Jan 2008 16:24:56 -0800
> 
> > 	Following are seven patches to fix locking problems,
> > silence locking-related warnings and resolve one recent regression
> > in the current 2.6.24-rc.
> 
> Jeff, are you going to merge this stuff in?
> 
> I'll drop that rtnl_lock() one-liner if so...

It's all in mainline.  The one-liner should be unneeded.
