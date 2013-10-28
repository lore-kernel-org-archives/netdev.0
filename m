From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] vxlan: silence one build warning
Date: Mon, 28 Oct 2013 00:38:07 -0400 (EDT)
Message-ID: <20131028.003807.1591686723281776238.davem@davemloft.net>
References: <1382687360-27794-1-git-send-email-zwu.kernel@gmail.com>
	<20131025084134.6cfa153a@samsung-9>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zwu.kernel@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, wuzhy@linux.vnet.ibm.com
To: stephen@networkplumber.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131025084134.6cfa153a@samsung-9>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 25 Oct 2013 08:41:34 -0700

> I would rather not fix the warning this way since it risks masking
> later bugs if this code ever changes.

But this is suboptimally coded, and is asking for the warning.

Anything returning a pointer by reference is asking for trouble
in my opinion.

The correct thing to do is to make create_v{4,6}_sock() return
the "struct socket *" as an error pointer.

No more ambiguous initializations, no more warnings.
