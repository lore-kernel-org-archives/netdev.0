From: Marcela Maslanova <mmaslano@redhat.com>
Subject: [Iproute2]: failed replacing internal netem qdisc with pfifo
Date: Thu, 13 Aug 2009 06:26:40 -0400 (EDT)
Message-ID: <2036847082.914731250159200857.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
References: <1937368901.914631250159066876.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41247 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750852AbZHMK0m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 06:26:42 -0400
In-Reply-To: <1937368901.914631250159066876.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I've received bug report about not being replaced netem with pfifo
anymore: https://bugzilla.redhat.com/show_bug.cgi?id=3D515522
This should be possible according to documentation [1].
Is this intentional change or is it a bug?

It worked with kernel-2.6.27.5-117.fc10 and iproute-2.6.27. The problem
is still present with current iproute and kernel-2.6.29.6-217.2.3.fc11.

Best regards,
Marcela Ma=C5=A1l=C3=A1=C5=88ov=C3=A1

[1] http://www.linuxfoundation.org/en/Net:Netem#How_to_reorder_packets_=
based_on_jitter.3F
