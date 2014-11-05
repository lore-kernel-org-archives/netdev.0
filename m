From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net v3] ipv6: mld: fix add_grhead skb_over_panic for devs
 with large MTUs
Date: Wed, 05 Nov 2014 18:59:36 +0100
Message-ID: <545A6588.3090602@redhat.com>
References: <1415198530-7126-1-git-send-email-dborkman@redhat.com>  <1415204413.13896.5.camel@edumazet-glaptop2.roam.corp.google.com>  <1415205483.3264462.187432293.00A1F284@webmail.messagingengine.com> <1415206106.13896.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, lw1a2.jing@gmail.com, fw@strlen.de,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	David L Stevens <david.stevens@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48915 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751259AbaKER7z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 12:59:55 -0500
In-Reply-To: <1415206106.13896.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2014 05:48 PM, Eric Dumazet wrote:
> On Wed, 2014-11-05 at 17:38 +0100, Hannes Frederic Sowa wrote:
...
>> I would still vote for this version, but see the problem with the noise
>> caused by newline updates. Eric, would you mind a new version with only
>> the essential parts changed and keeping this calculation so we don't
>> need to change it twice for net and for net-next?
>
> I will be happy to review a v4 ;)

No problem, I'll respin. ;)

Thanks,
Daniel
