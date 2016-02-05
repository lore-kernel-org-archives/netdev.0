From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: [V4.4-rc6 Regression] af_unix: Revert 'lock_interruptible' in stream
 receive code
Date: Fri, 5 Feb 2016 13:50:44 -0500
Message-ID: <56B4EF04.2060407@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: hannes@stressinduktion.org,
	"davem@davemloft.net" <davem@davemloft.net>, edumazet@google.com,
	dhowells@redhat.com, ying.xue@windriver.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: rweikusat@mobileactivedefense.com
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rainer,

A kernel bug report was opened against Ubuntu [0].  After a kernel
bisect, it was found that reverting the following commit resolved this bug:

commit 3822b5c2fc62e3de8a0f33806ff279fb7df92432
Author: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Date:   Wed Dec 16 20:09:25 2015 +0000

    af_unix: Revert 'lock_interruptible' in stream receive code

      
The regression was introduced as of v4.4-rc6.

I was hoping to get your feedback, since you are the patch author.  Do
you think gathering any additional data will help diagnose this issue,
or would it be best to submit a revert request?

    
Thanks,
    
Joe

[0] http://pad.lv/1540731
