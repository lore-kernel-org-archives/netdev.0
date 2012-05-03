From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0x277/0x280()
Date: Thu, 3 May 2012 08:47:26 +0200
Message-ID: <20120503064726.GA17337@electric-eye.fr.zoreil.com>
References: <4F92EC8D.2010806@fiec.espol.edu.ec> <4FA18919.8010503@fiec.espol.edu.ec> <20120502225227.GA12309@electric-eye.fr.zoreil.com> <4FA1C331.80909@fiec.espol.edu.ec>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alex =?utf-8?B?VmlsbGFjw63CrXM=?= Lasso
	<avillaci@fiec.espol.edu.ec>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46168 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752455Ab2ECGxW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 02:53:22 -0400
Content-Disposition: inline
In-Reply-To: <4FA1C331.80909@fiec.espol.edu.ec>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(please avoid posting twice)

Alex Villac=C3=AD=C2=ADs Lasso <avillaci@fiec.espol.edu.ec> :
[...]
> I am currently away from the target computer. How should I check for =
this? lspci?

lspci can not tell much. Use 'dmesg | grep XID' instead.

A complete dmesg would be welcome.

It could help to know a few things :
- does the problem qualify as a regression since some kernel version ?
  If so which one ?
- can it be reproduced with a kernel that has not been vbox tainted ?
- does networking recover ?

Thanks.

--=20
Ueimor
