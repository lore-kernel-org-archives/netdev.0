From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Tue, 08 Apr 2008 17:45:25 +0200
Message-ID: <47FB9315.5030109@trash.net>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr>	<873apwrc4t.fsf@basil.nowhere.org> <47FB60EF.1080004@trash.net> <7iy77o9wzb.fsf@lanthane.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42817 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbYDHPp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 11:45:28 -0400
In-Reply-To: <7iy77o9wzb.fsf@lanthane.pps.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Juliusz Chroboczek wrote:
>>> I think we have multiple qdiscs now doing very similar such hashes.
>>> Any chance this could be factored out into a common library function
>>> first?
> 
>> I'd suggest to use the flow classifier for this. For simplicity
>> you could attach a default classifier that uses the same keys as
>> this one.
> 
> I'm not sure I know what you're speaking about.  Could you please
> point me at code somewhere?

Check out a recent tree (either Linus' current tree or ideally
the net-2.6.26.git tree from

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.26.git

and look at net/sched/cls_flow.c and the recent changes to
net/sched/sch_sfq.c for external classifiers. There are also
a number of other incompatible changes that your patch needs
to be adapter to, most importantly the use of the new netlink
infrastructure.
