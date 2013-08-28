From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: [v3.11][Regression] skge: add dma_mapping check
Date: Wed, 28 Aug 2013 11:20:50 -0400
Message-ID: <521E1552.4010100@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>, mlindner@marvell.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

A bug was opened against the Ubuntu kernel[0].  A bug has also been
opened in bugzilla[1].  After a kernel bisect, it was found that
reverting the following commit resolved this bug:

commit 136d8f377e1575463b47840bc5f1b22d94bf8f63
Author: stephen hemminger <stephen@networkplumber.org>
Date:   Sun Aug 4 17:22:34 2013 -0700

    skge: add dma_mapping check


The regression was introduced as of v3.11-rc6.

I see that you are the author of this patch, so I wanted to run this by
you.  I was thinking of requesting a revert for v3.11, but I wanted to
get your feedback first.


Thanks,

Joe

[0] https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1216745
[1] https://bugzilla.kernel.org/show_bug.cgi?id=60784
