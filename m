From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] bridge and friends: reduce TheLinuxWay(tm)
Date: Wed, 16 Oct 2013 11:35:50 -0700
Message-ID: <1381948550.2045.136.camel@edumazet-glaptop.roam.corp.google.com>
References: <525C62D5.3090004@mojatatu.com>
	 <20131014144156.6dc52a78@nehalam.linuxnetplumber.net>
	 <525E9AB1.6090502@mojatatu.com> <525EC8AF.6000902@redhat.com>
	 <525ED1AE.7050101@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:54451 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761899Ab3JPSfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 14:35:53 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so1179573pbc.35
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 11:35:52 -0700 (PDT)
In-Reply-To: <525ED1AE.7050101@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-16 at 13:49 -0400, Jamal Hadi Salim wrote:

> I think we need some filtering in the kernel. As it stands today,
> unfortunately you get everything ;-> I was suprised at the amount of
> data i get from the kernel these days when i ask for a simple netdev
> info (I think no less than 1K per netdev; everything from /proc entries
> from some bread crumbs i dont see any use for.

By the way, "ip link show dev xxxx" seems to dump all devices info from
the kernel...
