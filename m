From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: revert "add byte queue limit support".
Date: Tue, 24 Jul 2012 07:38:11 +0200
Message-ID: <20120724053811.GA12053@electric-eye.fr.zoreil.com>
References: <20120723205555.GA4392@electric-eye.fr.zoreil.com> <1343106407.2626.11038.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hayeswang@realtek.com,
	netdev@vger.kernel.org,
	Alex =?utf-8?B?VmlsbGFjw61z?= Lasso <a_villacis@palosanto.com>,
	Josh Boyer <jwboyer@redhat.com>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:35139 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753653Ab2GXFvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 01:51:38 -0400
Content-Disposition: inline
In-Reply-To: <1343106407.2626.11038.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> :
> On Mon, 2012-07-23 at 22:55 +0200, Francois Romieu wrote:
> > This reverts commit 036dafa28da1e2565a8529de2ae663c37b7a0060.
[...]
> bisection is not always the right way to qualify a problem.

I know. At some point I switch from "I could search more" to "users situation
will improve in a definite timeframe".

> BQL in itself had some fixes coming _after_ commit 036dafa28da1e2565

Thanks.

They are in stable as of 3.4.5:

commit 4f4bdaeb40df95499c1ee7ea3fbca9d76174a59e
Author:     Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
AuthorDate: Wed May 30 12:25:37 2012 +0000
Commit:     Greg Kroah-Hartman <gregkh@linuxfoundation.org>
CommitDate: Mon Jul 16 09:03:43 2012 -0700

    bql: Avoid possible inconsistent calculation.
    
    [ Upstream commit 914bec1011a25f65cdc94988a6f974bfb9a3c10d ]
[...]
commit 1414a53d956340ca8b1b27e05ab94ba63e82ed97
Author:     Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
AuthorDate: Wed May 30 12:25:19 2012 +0000
Commit:     Greg Kroah-Hartman <gregkh@linuxfoundation.org>
CommitDate: Mon Jul 16 09:03:43 2012 -0700

    bql: Avoid unneeded limit decrement.

I have obviously not directed users at them and I do not see any
of the victims using a non -stable / -vendor or recent enough
kernel to test this patch since the issue has been reported.

They are both worth testing.

> Is there an easy way to reproduce the problem ?

None here :o(

-- 
Ueimor
