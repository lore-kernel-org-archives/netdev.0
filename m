From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] ethernet/pch_gbe: Change company name OKI
 SEMICONDUCTOR to LAPIS Semiconductor
Date: Mon, 30 Jan 2012 12:52:19 -0500 (EST)
Message-ID: <20120130.125219.2077768183344205118.davem@davemloft.net>
References: <1327643159-1302-1-git-send-email-tomoya.rohm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, qi.wang@intel.com, yong.y.wang@intel.com,
	joel.clark@intel.com, kok.howg.ewe@intel.com
To: tomoya.rohm@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327643159-1302-1-git-send-email-tomoya.rohm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Sorry, we're not going to get into this pattern where we move drivers
around in the tree every time the company that produces the chip
changes it's name.

If we did this then certain drivers will have moved 5 or more times
since the beginning of the Linux kernel, and there is nothing to be
gained from that except confusion.

In fact more valuable thing to do is to refer to both the old and the
new name, rather than just the new one or just the old one.  Because
you now have two sets of users, one very large set which is familiar
with the old name and a smaller set which will only know about the new
name.

Frankly, I would just leave everything alone except perhaps adding a
mention of the new name (and not deleting the old name) in the Kconfig
help text.
