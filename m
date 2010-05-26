From: Jon Zhou <Jon.Zhou@jdsu.com>
Subject: why the number of queue of NIC  impact the ping results?
Date: Wed, 26 May 2010 02:01:37 -0700
Message-ID: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2498091D21@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og111.obsmtp.com ([64.18.2.175]:44639 "HELO
	exprod7og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752422Ab0EZJCl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 05:02:41 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

broadcom bnx2x netxtreme2-5.2.50,kernel 2.6.27-19

@receiver:

insmod ./bnx2x.ko  multi_mode=1 num_queues=12/14/16

@sender:
ping receiver ->response OK


but no response when

insmod ./bnx2x.ko  multi_mode=1 num_queues=2/4/8/10

have any idea?

thanks
jon



