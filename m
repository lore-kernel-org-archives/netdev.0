From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH] bonding: Fix initialize after use for 3ad machine state
 spinlock
Date: Mon, 18 Feb 2013 18:43:13 +0100
Message-ID: <51226831.4030105@redhat.com>
References: <1361191541-7654-1-git-send-email-nikolay@redhat.com> <20130218.120232.679284201789150959.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34238 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756339Ab3BRRne (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 12:43:34 -0500
In-Reply-To: <20130218.120232.679284201789150959.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/02/13 18:02, David Miller wrote:
> 
> When submitting multiple changes to the same area in a group, you must
> number your changes.
> 
> Using tools such as "git send-email ..." will do this automatically
> for you, otherwise you must put numberings into your subject lines
> by hand.

Thanks for the advice, I must've accidentally removed the numbering
while re-basing as I used git send-email.
Should I post a v2 with numbering ?
The actual order of applying these 2 doesn't matter as they touch
different parts, and if applied in reverse will only spill an offset -1.

Nik
