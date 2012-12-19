From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139cp: Prevent dev_close/cp_interrupt race on MTU
 change
Date: Wed, 19 Dec 2012 12:40:14 -0800 (PST)
Message-ID: <20121219.124014.891279563982531558.davem@davemloft.net>
References: <1355946468-3290-1-git-send-email-jogreene@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David.Woodhouse@intel.com
To: jogreene@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49279 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597Ab2LSUkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 15:40:15 -0500
In-Reply-To: <1355946468-3290-1-git-send-email-jogreene@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Greene <jogreene@redhat.com>
Date: Wed, 19 Dec 2012 14:47:48 -0500

> commit:  cb64edb6b89491edfdbae52ba7db9a8b8391d339 upstream
> 
> Above commit may introduce a race between cp_interrupt and dev_close
> / change MTU / dev_open up state. Changes cp_interrupt to tolerate
> this.  Change spin_locking in cp_interrupt to avoid possible
> but unobserved race.
> 
> Reported-by: "Francois Romieu" <romieu@fr.zoreil.com>
> 
> Tested on virtual hardware, Tx MTU size up to 4096, max tx payload
>     was ping -s 4068 for MTU of 4096. No real hardware, need test
>     assist.
> 
> Signed-off-by: "John Greene" <jogreene@redhat.com>

You sent this as a "request for testing" last week, but I saw
no testing on real hardware whatsoever.
