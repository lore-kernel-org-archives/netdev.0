From: Richard =?ISO-8859-1?Q?R=F6jfors?=
	<richard.rojfors@pelagicore.com>
Subject: [PATCH v3 0/2] ks8842: Do the TX timeout work in workqueue context.
Date: Fri, 09 Jul 2010 08:28:09 +0200
Message-ID: <1278656889.6953.13.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h21.telenor.se ([195.54.99.196]:52967 "EHLO
	smtprelay-h21.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375Ab0GIGsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:48:55 -0400
Received: from ipb1.telenor.se (ipb1.telenor.se [195.54.127.164])
	by smtprelay-h21.telenor.se (Postfix) with ESMTP id 10EB2E8FAF
	for <netdev@vger.kernel.org>; Fri,  9 Jul 2010 08:28:11 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To follow are two patches. One that schedules tx timeout to be done
in work queue context.

The other removed an unnecessary bank select before reset.

--Richard

