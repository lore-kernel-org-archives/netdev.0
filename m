From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: WARNING: at net/core/dst.c:265 dst_release+0x3a/0x40()
Date: Wed, 29 Oct 2008 18:03:12 -0700
Message-ID: <20081029180312.35359dec@extreme>
References: <490905F8.7060908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: John Daiker <daikerjohn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44301 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751103AbYJ3BDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 21:03:20 -0400
In-Reply-To: <490905F8.7060908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Oct 2008 17:55:20 -0700
John Daiker <daikerjohn@gmail.com> wrote:

> Leaving my machine up all day, running Folding@Home with litte to no network activity, I find my machine at a hard lockup (flashing CAPS lock, unresponsive to keyboard and mouse input).  This forces a hard reset, and unfortunately removes any further clues...
> 
> This has occurred once each on both 2.6.27.3 and 2.6.27.4
> 
> I have attached a dmesg output as well as my 2.6.27.4 config file.  I can debug if necessary, just tell me what CONFIG parameters to change and what boot options to enable and I'm on it
> 
> PreScript> Please Reply-All as I am not on the netdev mailing list...
> 
> Thanks,
> John Daiker
> 

Please reproduce without any proprietary modules loaded.

[63544.820178] Pid: 9, comm: events/0 Tainted: P          2.6.27.4-20081027-184627 #1
[63544.820179] 
[63544.820179] Call Trace:
