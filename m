From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] sit: add support of x-netns
Date: Wed, 26 Jun 2013 03:22:16 -0700
Message-ID: <1372242136.3301.162.camel@edumazet-glaptop>
References: <1372170295-4717-3-git-send-email-nicolas.dichtel@6wind.com>
	 <20130625.165612.1653110297729408070.davem@davemloft.net>
	 <87d2r964d9.fsf@xmission.com>
	 <20130625.224810.293452557691677283.davem@davemloft.net>
	 <87ppv942ad.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, nicolas.dichtel@6wind.com,
	netdev@vger.kernel.org, bcrl@kvack.org, ravi.mlists@gmail.com,
	bhutchings@solarflare.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:37151 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513Ab3FZKWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 06:22:14 -0400
Received: by mail-ee0-f54.google.com with SMTP id t10so7384005eei.13
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 03:22:13 -0700 (PDT)
In-Reply-To: <87ppv942ad.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-26 at 03:03 -0700, Eric W. Biederman wrote:


> That said I won't object if Nocolas Ditchel resends his patches with
> that test put back in.  I just think it is silly and when someone
> finally gets bit by the bug and complains we will have to go through and
> remove the test.

Well, what is the reason skb_orphan() must be called in a tunnel xmit
path ?

This patch changes more things than what advertised in changelog :(
