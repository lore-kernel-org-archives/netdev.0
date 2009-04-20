From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] syncookies: remove last_synq_overflow from struct tcp_sock
Date: Mon, 20 Apr 2009 12:13:49 +0200
Message-ID: <87iqkzpr8i.fsf@basil.nowhere.org>
References: <1240170228-26241-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:55467 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbZDTKNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 06:13:51 -0400
In-Reply-To: <1240170228-26241-1-git-send-email-fw@strlen.de> (Florian Westphal's message of "Sun, 19 Apr 2009 21:43:48 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal <fw@strlen.de> writes:
>
> We can (ab)use rx_opt.ts_recent_stamp to store the same information;
> it is not used otherwise as long as a socket is in listen state.

You should add a comment to the declaration of the structure for this.
Or better use a union to make it clear.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
