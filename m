From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: NAPI and shared interrupt control
Date: Thu, 7 Dec 2006 02:22:57 -0800
Message-ID: <20061207102257.GC19479@gate.ebshome.net>
References: <20061207094502.GA19479@gate.ebshome.net> <20061207.015954.52181319.davem@davemloft.net> <20061207101555.GB19479@gate.ebshome.net> <20061207.022010.120465413.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.ebshome.net ([208.106.21.240]:47974 "EHLO gate.ebshome.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031978AbWLGKW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 05:22:57 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061207.022010.120465413.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 07, 2006 at 02:20:10AM -0800, David Miller wrote:
> It also just occured to me that even if you use the dummy device
> approach, it's the dummy device's quota that will be used by the
> generic ->poll() downcall into the driver.

Yes, that's true. That's why I made this parameter 
Konfig-configurable. Yes, this is not as flexible as run-time 
configuration available for a real netdev, but better than nothing and 
nobody has complained yet :)

-- 
Eugene

