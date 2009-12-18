From: Stefano Salsano <stefano.salsano@uniroma2.it>
Subject: [PATCH] netem/iproute2 solving correlated loss issues [0/5]
Date: Fri, 18 Dec 2009 11:39:13 +0100
Message-ID: <4B2B5BD1.7040602@uniroma2.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Fabio Ludovici <fabio.ludovici@yahoo.it>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.uniroma2.it ([160.80.6.16]:56729 "EHLO smtp.uniroma2.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752216AbZLRKpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2009 05:45:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear all,

we are going to send a patch that enhances netem module and the iproute2
utilities.

Our aim is to fix the problems with correlated loss generation in netem
(as for example described in
https://lists.linux-foundation.org/pipermail/netem/2007-September/001156.html)

We have now included a more general loss model, as described in:
http://netgroup.uniroma2.it/twiki/bin/view.cgi/Main/NetEm2

The patch is backward compatible, we have not removed the previous
correlated loss generated approach (though its use should be
deprecated), nor we have changed anything else in the existing netem
module.

Within our patch for iproute2 we also added a man page for netem (it was
missing) in which we have pasted the existing documentation for netem
and the usage of our model.

We had posted this work on the netem mailing list some months ago as a
separate netem2 module... we received some feedback and made some bug
fix since then. We believe the work is now ready to be inserted in the
main netem/iproute2 development.

We will post in next messages the patches to netem module for 2.6.32
kernel and to 2.6.29 iproute2 (find below the list)

Comments are welcome.
Best regards,
Stefano and Fabio

netem kernel module patches:

patch 1/5 : linux-2.6.32/include/linux/pkt_sched.h
patch 2/5 : net/sched/sch_netem.c

iproute2 utilities patches:

patch 3/5 : iproute2-2.6.29-1/include/linux/pkt_sched.h
patch 4/5 : iproute2-2.6.29-1/man/man8/tc-netem.8
patch 5/5 : iproute2-2.6.29-1/tc/q_netem.c


-- 
*******************************************************************
Stefano Salsano
Dipartimento Ingegneria Elettronica
Universita' di Roma "Tor Vergata"
Via del Politecnico, 1 - 00133 Roma - ITALY

http://netgroup.uniroma2.it/Stefano_Salsano/

E-mail  : stefano.salsano@uniroma2.it
Cell.   : +39 320 4307310
Office  : (Tel.) +39 06 72597770  (Fax.) +39 06 72597435
*******************************************************************

