From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v4 net-next 0/6] bnx2x: refactor nvram related code and
 update version
Date: Mon, 22 Apr 2013 16:48:05 +0300
Message-ID: <1366638491-27184-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: romieu@fz.zoreil.com, "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3276 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751466Ab3DVNsZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 09:48:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Please cosider appliyng the series to net-next.

Changes for v2->v3:
1/4 	* was separated into 3 patches [1-3/6] pointed out by Francois Romieu
	* some cosmetics and beautifications was applied.
	* bnx2x_nvram_read32 rearranged according to Francois Romieu's comments
	 
2/4	* move to be 4/6
	* some code were extracted into fuctions in order to stop processing
          once error was detected.
	* removed inaccurate decoding of errors - left only error messages
          according to Francois Romieu's comments
	* removed useless init according to Francois Romieu's comment

Changes for v3->v4
4/6	* removed some emtry lines
	* fixed lines over 80 chars

Thanks
Dmitry
