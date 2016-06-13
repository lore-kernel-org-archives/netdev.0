From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/3] s390: af_iucv patches
Date: Mon, 13 Jun 2016 18:46:13 +0200
Message-ID: <1465836376-24452-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:63628 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964994AbcFMQq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:46:56 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5DGhvpJ085010
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 12:46:56 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23get1naew-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 12:46:55 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Mon, 13 Jun 2016 17:46:54 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are improvements for af_iucv relaxing the pressure to allocate
big contiguous kernel buffers.

Thanks, Ursula

Eugene Crosser (3):
  af_iucv: use paged SKBs for big outbound messages
  af_iucv: remove fragment_skb() to use paged SKBs
  af_iucv: use paged SKBs for big inbound messages

 net/iucv/af_iucv.c | 223 +++++++++++++++++++++++++++++------------------------
 1 file changed, 122 insertions(+), 101 deletions(-)

-- 
2.6.6
