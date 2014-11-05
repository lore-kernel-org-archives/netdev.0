From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v3] ipv6: mld: fix add_grhead skb_over_panic for
 devs with large MTUs
Date: Wed, 05 Nov 2014 08:48:26 -0800
Message-ID: <1415206106.13896.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415198530-7126-1-git-send-email-dborkman@redhat.com>
	 <1415204413.13896.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1415205483.3264462.187432293.00A1F284@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	lw1a2.jing@gmail.com, fw@strlen.de, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	David L Stevens <david.stevens@oracle.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:38242 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932263AbaKEQs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 11:48:29 -0500
Received: by mail-ie0-f175.google.com with SMTP id y20so1080551ier.34
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 08:48:29 -0800 (PST)
In-Reply-To: <1415205483.3264462.187432293.00A1F284@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-05 at 17:38 +0100, Hannes Frederic Sowa wrote:

> I would still vote for this version, but see the problem with the noise
> caused by newline updates. Eric, would you mind a new version with only
> the essential parts changed and keeping this calculation so we don't
> need to change it twice for net and for net-next?

I will be happy to review a v4 ;)

Thanks !
