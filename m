From: Ted Percival <ted@tedp.id.au>
Subject: Solved: Regression: TCP connections fail over wireless: bad checksum
Date: Fri, 5 Sep 2014 09:29:16 -0600
Message-ID: <5409D6CC.3040409@tedp.id.au>
References: <5408C788.4050401@tedp.id.au>	 <1409871007.26422.125.camel@edumazet-glaptop2.roam.corp.google.com>	 <5408F3FB.2010107@tedp.id.au>	 <CA+mtBx-5j0o6ZWhzXidLPG28ZnHBvSeCJ+hda5_hsu4Lq-_a=A@mail.gmail.com> <1409891901.26422.133.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amersmtp2.software.dell.com ([12.106.87.227]:37404 "EHLO
	amersmtp2.software.dell.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751961AbaIEP2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 11:28:22 -0400
Received: from amersmtp2.prod.quest.corp (127.0.0.1) id h17b9c0171s2 for <netdev@vger.kernel.org>; Fri, 5 Sep 2014 08:28:21 -0700 (envelope-from <ted@tedp.id.au>)
In-Reply-To: <1409891901.26422.133.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04/2014 10:38 PM, Eric Dumazet wrote:
> Most probably this is already fixed in net-next tree
> 
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=1f59533f9ca5634e7b8914252e48aee9d9cbe501

Yep. 50cbe9ab5f8d was the regressing commit and cherry-picking that
commit on top of it solves the problem.
