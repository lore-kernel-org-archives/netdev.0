From: "David S. Miller" <davem@redhat.com>
Subject: Re: patch for common networking error messages
Date: Tue, 17 Jun 2003 14:14:43 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617.141443.24610277.davem@redhat.com>
References: <OFDF06338E.06BC4D08-ON85256D48.00729284@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: girouard@us.ibm.com
In-Reply-To: <OFDF06338E.06BC4D08-ON85256D48.00729284@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Janice Girouard <girouard@us.ibm.com>
   Date: Tue, 17 Jun 2003 15:57:59 -0500
   
   Did I understand:
   
   > 1) Chip has a "flow cache", LRU based, managed like routing caches
   
   You need the chip to support your technique.

No shit Sherlock.

But it should be noted that the idea can be fully verified in software
by adding the scheme into the RX processing of some existing ethernet
driver.

   Are the vendors picking up on this?

If they're going to ignore my ideas, that's not my problem.

   I still don't see how this gets rid of the copy_to_user space once
   you've gathered the buffers.  How do you feed the user buffer addresses to
   the card?

You flip the pages into userspace, ie. you replace the page the user
currently has with the one the networking buffer is using.

   What technique are you using?  Is it proprietary?

ROFL!
