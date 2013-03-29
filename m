From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: [v3.8, v3.9] [Regression] brcmsmac: move PHY functions
Date: Fri, 29 Mar 2013 15:52:39 -0400
Message-ID: <5155F107.6050408@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: arend@broadcom.com, pieterpg@broadcom.com, meuleman@broadcom.com,
	phaber@broadcom.com, linville@tuxdriver.com,
	LKML <linux-kernel@vger.kernel.org>, brudley@broadcom.com,
	frankyl@broadcom.com, linux-wireless@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, netdev@vger.kernel.org
To: phaber@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Piotr,

A bug was opened against the Ubuntu kernel[0].  After a kernel
bisect, it was found that reverting the following commit resolved
this bug:

commit b83576341664957978e125f5f5db2f15496980b1
Author: Piotr Haber <phaber@broadcom.com>
Date:   Wed Nov 28 21:44:09 2012 +0100

     brcmsmac: move PHY functions

The regression was introduced as of v3.8-rc1.  The regression still 
exists in v3.9-rc4.

I see that you are the author of this patch, so I wanted to run this
by you.  I was thinking of requesting a revert for v3.9, but I
wanted to get your feedback first.


Thanks,

Joe

[0] http://pad.lv/1131914
