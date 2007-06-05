From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 05 Jun 2007 07:50:31 -0400
Message-ID: <1181044231.4075.51.camel@localhost>
References: <20070604214037.1524.58506.stgit@localhost.localdomain>
	 <20070604214045.1524.18254.stgit@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	auke-jan.h.kok@intel.com
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:19378 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754715AbXFELui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 07:50:38 -0400
Received: by py-out-1112.google.com with SMTP id a29so2819931pyi
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2007 04:50:38 -0700 (PDT)
In-Reply-To: <20070604214045.1524.18254.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-04-06 at 14:40 -0700, PJ Waskiewicz wrote:
> API added to support multiple hardware queues on an ethernet device.
>     Round-robin scheduler added (sch_rr) to provide a no-scheduling policy
>     qdisc for hardware with multiple queues.
> 

>From a high level i see a good start that you at least have a separate
qdisc. I dont see the need for making any subqueue semantics in the
qdisc. We already have them.
I also still dont see the need for the patching of the prio qdisc or the
subqueue control.
I am now uncertain that after all those discussions (and a lot other
private ones) whether you understood me. We are still not meeting in the
middle. 

Sorry, Peter i dont mean to rain on your parade but i cant let this just
slide by[1]. So please give me sometime and this week i will send
patches to demonstrate my view. I didnt mean to do that, but as i see it
i have no other choice.

BTW, wheres the e1000 change?

cheers,
jamal

[1] If for example you wrote a classifier or a qdisc (as in a recent
discussion I had with Patrick) i would say it is your code and your
effort and i have the choice not to use it (by virtue of there being
other alternatives). I have no such luxury but to use the changes you
make to that code path whenever i use multi tx rings.

PS:- It is polite to CC someone who has engaged you in a conversation;
in particular as i have told you before at times i dont read netdev for
days but read emails addressed to me even when busyed out or travelling.

