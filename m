From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git)] STMMAC: fix TX Normal descriptor
Date: Wed, 16 Mar 2016 11:21:48 +0100
Message-ID: <1458123709-19692-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <gabriel.fernandez@linaro.org>, <afaerber@suse.de>,
	<fschaefer.oss@googlemail.com>, <dinh.linux@gmail.com>,
	<davem@davemloft.net>, <preid@electromag.com.au>,
	<tomeu@tomeuvizoso.net>, <fabrice.gasnier@st.com>,
	<alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:31231 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966153AbcCPKQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 06:16:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On top of the Oct_2015 driver version committed into net-next, this patch
fixes a problem for the HW where the normal descriptor are used at runtime
instead of the Enhanced/Alternate descriptors.
In the beginning, it was suggested to revert the patch:
  "stmmac: first frame prep at the end of xmit routine"
and it has been noticed that w/o it the normal TDES 0 and 1 were good filled.

Then has been proposed this new fix (w/o reverting the patch above).

Giuseppe Cavallaro (1):
  stmmac: fix TX normal DESC

 drivers/net/ethernet/stmicro/stmmac/norm_desc.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

-- 
1.7.4.4
