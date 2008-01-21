From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] net: add sparse annotation to ptype_seq_start/stop
Date: Mon, 21 Jan 2008 05:28:31 +0000
Message-ID: <20080121052831.GF27894@ZenIV.linux.org.uk>
References: <20080120152146.70bc0b12@deepthought> <20080121050355.GD7541@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	josh@freedesktop.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:42978 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbYAUF2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 00:28:47 -0500
Content-Disposition: inline
In-Reply-To: <20080121050355.GD7541@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 20, 2008 at 09:03:55PM -0800, Paul E. McKenney wrote:
> On Sun, Jan 20, 2008 at 03:21:46PM -0800, Stephen Hemminger wrote:
> > Get rid of some more sparse warnings.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Adding Josh to CC -- is __acquires() case-insensitive?  If not, this
> needs to be __acquires(RCU) and __releases(RCU).

__acquires(whatever_the_helk_you_put_as_its_argument) is all the same.
