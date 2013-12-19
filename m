From: Manish Chopra <manish.chopra@qlogic.com>
Subject: RE: [PATCH 1/2] netxen: Correct off-by-one error in bounds check
Date: Thu, 19 Dec 2013 11:51:37 +0000
Message-ID: <31AFFC7280259C4184970ABA9AFE8B938CF86A62@avmb3.qlogic.org>
References: <1387257753-18676-1-git-send-email-david@gibson.dropbear.id.au>
 <1387257753-18676-2-git-send-email-david@gibson.dropbear.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	"snagarka@redhat.com" <snagarka@redhat.com>,
	"tcamuso@redhat.com" <tcamuso@redhat.com>,
	"vdasgupt@redhat.com" <vdasgupt@redhat.com>
To: David Gibson <david@gibson.dropbear.id.au>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:47570 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753043Ab3LSLvq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 06:51:46 -0500
In-Reply-To: <1387257753-18676-2-git-send-email-david@gibson.dropbear.id.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Gibson [mailto:david@gibson.dropbear.id.au]
>Sent: Tuesday, December 17, 2013 10:53 AM
>To: Manish Chopra; Sony Chacko; Rajesh Borundia
>Cc: netdev; snagarka@redhat.com; tcamuso@redhat.com;
>vdasgupt@redhat.com; David Gibson
>Subject: [PATCH 1/2] netxen: Correct off-by-one error in bounds check
>
>After retrieving an Rx buffer index from the hardware, the netxen driver bounds
>checks it against its array of receive buffers.  However in the case of LRO packets,
>there's an off-by-one error in the check - it uses > instead of the >= it uses for the
>normal receive path in netxen_process_rcv().
>
>Signed-off-by: David Gibson <david@gibson.dropbear.id.au>

Acked-by: Manish Chopra <manish.chopra@qlogic.com>

Thanks David. This is really a bug fix. You can re-submit this single patch.
