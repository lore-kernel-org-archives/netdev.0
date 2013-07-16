From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: [Regression][v3.10][v3.11] net: Kill link between CSUM and SG features.
Date: Tue, 16 Jul 2013 14:09:09 -0400
Message-ID: <51E58C45.1080708@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ben.howard@canonical.com, edumazet@google.com,
	xiyou.wangcong@gmail.com, alexander.h.duyck@intel.com,
	jiri@resnulli.us, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, kys@microsoft.com,
	haiyangz@microsoft.com
To: pshelar@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pravin,

A bug was opened against the Ubuntu kernel[0].  After a kernel bisect,
it was found that reverting the following commit resolved this bug:

commit ec5f061564238892005257c83565a0b58ec79295
Author: Pravin B Shelar <pshelar@nicira.com>
Date:   Thu Mar 7 09:28:01 2013 +0000

    net: Kill link between CSUM and SG features.


The regression was introduced as of v3.10-rc1.

I see that you are the author of this patch, so I wanted to run this by
you.  I was thinking of requesting a revert for v3.11, but I wanted to
get your feedback first.


Thanks,

Joe

[0] http://pad.lv/1200243
