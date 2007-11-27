From: Patrick McHardy <kaber@trash.net>
Subject: Re: Does tc-prio really work as advertised?
Date: Tue, 27 Nov 2007 14:18:38 +0100
Message-ID: <474C192E.9080608@trash.net>
References: <677950.98010.qm@web51406.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
To: Joerg Pommnitz <pommnitz@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59159 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661AbXK0NSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 08:18:48 -0500
In-Reply-To: <677950.98010.qm@web51406.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joerg Pommnitz wrote:
> Great :-(. I went over the ChangeLogs for later kernel versions, but
> couldn't find anything.
> 
> I'll try to come up with a working .config for the most current kernel
> that works on my hardware and test again.
> 
> Do you have a pointer to the fix so that I could try to patch a 2.6.20
> kernel?

git-log net/sched/sch_prio.c:

commit dbaaa07a60edf71670b484a65e14400ab40c84f7
Author: Lucas Nussbaum <lucas.nussbaum@imag.fr>
Date:   Thu Aug 30 22:35:46 2007 -0700

     [NET_SCHED] sch_prio.c: remove duplicate call of tc_classify()

and

commit bdba91ec70fb5ccbdeb1c7068319adc6ea9e1a7d
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Jul 30 17:07:14 2007 -0700

     [NET_SCHED]: Fix prio/ingress classification logic error

Feel free to send patches against the still maintained -stable versions.
