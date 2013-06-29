From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v2] gre: fix a regression in ioctl
Date: Sat, 29 Jun 2013 11:55:39 +0800
Message-ID: <1372478139.29178.6.camel@cr0>
References: <1372471480-28992-1-git-send-email-amwang@redhat.com>
	 <1372472672-1900-1-git-send-email-amwang@redhat.com>
	 <CALnjE+qo33kqer_JQVwC+FDpmrSYpU2WkiYqeN6R11OWQkocug@mail.gmail.com>
	 <1372476822.29178.3.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54668 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751845Ab3F2Dzr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jun 2013 23:55:47 -0400
In-Reply-To: <1372476822.29178.3.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-29 at 11:33 +0800, Cong Wang wrote:
> BTW, ipip has the same bug... I will send a patch for ipip too.

Pravin,

Any reason to add the following check for ipip?

       if (p.i_key || p.o_key || p.i_flags || p.o_flags)
               return -EINVAL;

It seems the old code doesn't have this check, you added it in commit
fd58156e456d9f68fe04486be378d0bc93641532 (IPIP: Use ip-tunneling code.).

This breaks the API?
