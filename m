From: "David S. Miller" <davem@redhat.com>
Subject: Re: skb_padto and small fragmented transmits
Date: 06 Feb 2003 03:58:14 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1044532694.7679.1.camel@rth.ninka.net>
References: <1044481190.9268.43.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Leech <christopher.leech@intel.com>
In-Reply-To: <1044481190.9268.43.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

skb_padto() only works on linear skb.

And if you look at all the drivers where it is used, they
do not enable things like scatter-gather.
