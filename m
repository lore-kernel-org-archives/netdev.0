From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: locking api self-test hanging
Date: Sun, 3 Feb 2008 15:07:44 -0800
Message-ID: <20080203150744.cf7d0415.akpm@linux-foundation.org>
References: <20080203150246.50647fa4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52381 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753323AbYBCXIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2008 18:08:14 -0500
In-Reply-To: <20080203150246.50647fa4.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 3 Feb 2008 15:02:46 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> With current mainline I'm getting intermittent hangs here:
> 
> 	http://userweb.kernel.org/~akpm/p2033590.jpg
> 
> with this config:
> 
> 	http://userweb.kernel.org/~akpm/config-sony.txt
> 
> on the Vaio.  Sometimes it boots (then hits another different hang),
> sometimes it gets stuck there.
> 

The second hang is in kobject_uevent_init().  All that function does is call
netlink_kernel_create().

These things make bisecting all the other bugs rather hard.
