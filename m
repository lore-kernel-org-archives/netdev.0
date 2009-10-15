From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 0/5] s390: networking patches for linux-next
Date: Thu, 15 Oct 2009 10:54:54 +0200
Message-ID: <20091015085454.124154000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:35844 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455AbZJOJI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 05:08:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

here are small improvements for net/iucv/ and drivers/s390/net/ .
They apply to linux-next.

Summary:

Hendrik Brueckner (1)
af_iucv: use sk functions to modify sk->sk_ack_backlog

Ursula Braun (1)
af_iucv: remove duplicate sock_set_flag

Klaus-Dieter Wacker (2)
lcs: ODEBUG: object is on stack, but not annotated.
lcs: Recognize return codes of ccw_device_set_online().

Einar Lueck (1)
ctcm: rollback in case of errors

Thanks,
        Ursula
