From: Christoph Hellwig <hch@lst.de>
Subject: Re: "net: remove sock_iocb" breaks ip tool - "Cannot send dump
	request : Connection refused"
Date: Thu, 5 Feb 2015 10:41:35 +0100
Message-ID: <20150205094135.GA2576@lst.de>
References: <1423128961.5723.10.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alban Browaeys <alban.browaeys@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:51759 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752911AbbBEJli (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 04:41:38 -0500
Content-Disposition: inline
In-Reply-To: <1423128961.5723.10.camel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 05, 2015 at 10:36:01AM +0100, Alban Browaeys wrote:
> "ip a" returns "Cannot send dump request : Connection refused" until I
> revert commit 7cc05662682d ("net: remove sock_iocb").
> This as root or as user.
> 
> NetworkManager is affected too.
> 
> Could siocb cache the cookie ? 

Ca you strace what syscall on what socket causes that return?
