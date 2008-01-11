From: Jeba Anandhan <jeba.anandhan@vaioni.com>
Subject: Improving performance of bonding driver (eql) using round robin
	alogrithm
Date: Fri, 11 Jan 2008 10:04:58 +0000
Message-ID: <1200045898.29856.57.camel@vglwks010.vgl2.office.vaioni.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vglsrv002.office.vaioni.com ([84.19.35.12]:9176 "EHLO
	vglsrv02.vgl2.office.vaioni.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755149AbYAKKGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 05:06:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,
The existing algorithm works in eql bonding driver works based on
priority of each slaves. The priority has been assigned as speed of the
particular line. The current problem is, all the slaves didn't get the
chance as best slave for the transmission.


Will the round robin algorithm for selecting best slave to transmit the
data, improves the performance?.

Thanks
Jeba
