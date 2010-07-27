From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 0/7] bnx2x: move bnx2x to separate folder and
 divide to files
Date: Tue, 27 Jul 2010 22:01:38 +0300
Message-ID: <1280257298.8566.8.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3643 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750858Ab0G0TQE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 15:16:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Please consider applying following patch series to the net-next.
The series creates separate folder for bxn2x files and divides
bnx2x_main file into several logical parts:
	bnx2x_cmn.[ch] - common functionality for PF and upcommimg 
			 VF drivers
	bnx2x_stat.[ch] - statistics handling
	ethtool.c - ethtool related function and structs

After applying this series, integration of latest bnx2x patches
from net-2.6 which include fixes for statistics handling can't
be performed in a "automatic" way then i can suggest to re-submitting
these two patches.

Dmitry
---



