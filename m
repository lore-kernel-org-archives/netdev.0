From: Willy Tarreau <w@1wt.eu>
Subject: Re: [IPv4] fib: Fix out of bound access of fib_props[]
Date: Sat, 14 Apr 2007 16:26:55 +0200
Message-ID: <20070414142655.GA21327@1wt.eu>
References: <20070324153435.GE521@postel.suug.ch> <20070324.203339.71087299.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1855 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030875AbXDNO1C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2007 10:27:02 -0400
Content-Disposition: inline
In-Reply-To: <20070324.203339.71087299.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 24, 2007 at 08:33:39PM -0700, David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Sat, 24 Mar 2007 16:34:36 +0100
> 
> > Fixes a typo which caused fib_props[] to have the wrong size
> > and makes sure the value used to index the array which is
> > provided by userspace via netlink is checked to avoid out of
> > bound access.
> > 
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Applied, thanks.

Thomas, David, it seems to me that 2.4 needs the same fix for the
typo, but I see no place where we may add the check for > RTN_MAX.
Maybe this last one is not needed. If someone could enlighten me,
or at least provide a means to test if the bug it present, it would
help me.

Thanks in advance,
Willy

