From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH 0/4] mISDN: Bugfixes for the mISDN DSP core
Date: Tue, 24 Apr 2012 14:51:48 +0200
Message-ID: <1335271912-5269-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:52065 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253Ab2DXMyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 08:54:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This collection are bugfixes for the DSP functions of the mISDN
core.
Tested against net-next.

Hopeful the submission format is OK now with git send-email
(before I used sendmail).


Andreas Eversberg (2):
  mISDN: Fix NULL pointer bug in if-condition of mISDN_dsp
  mISDN: Fixed hardware bridging/conference check routine of
    mISDN_dsp.ko.

Karsten Keil (2):
  mISDN: Fix division by zero
  mISDN: DSP scheduling fix

 drivers/isdn/mISDN/dsp.h      |    4 +++-
 drivers/isdn/mISDN/dsp_cmx.c  |   19 ++++++++++++-------
 drivers/isdn/mISDN/dsp_dtmf.c |   19 ++++++++++++++-----
 3 files changed, 29 insertions(+), 13 deletions(-)

-- 
1.7.3.4
