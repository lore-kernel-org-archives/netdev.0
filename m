From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: netfilter 02/02: xt_connlimit: fix regression caused by zero
 family value
Date: Thu, 5 Nov 2009 19:45:25 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0911051943130.25147@obet.zrqbmnf.qr>
References: <4AF31818.3030103@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:54729 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758441AbZKESpV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 13:45:21 -0500
In-Reply-To: <4AF31818.3030103@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2009-11-05 19:23, Patrick McHardy wrote:
>
>    netfilter: xt_connlimit: fix regression caused by zero family value
>    
>    Commit v2.6.28-rc1~7172~1092~2 was slightly incomplete; not all
>    instances of par->match->family were changed to par->family.
>    
>    Netfilter bugzilla #610.

Hold it.
git would never output ~7172~1092~2 because ~8266 would be much simpler.

I originally wrote "Commit v2.6.28-rc1~717^2~109^2~2", but one of your 
programs seems to eat commit messages or more.

(BTW, are not inline patches preferred for reply? Attachments do not 
automatically get quoted and I have to export it, reimport it, and
have it filtered through perl to add a >.)
