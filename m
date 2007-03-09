From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] myri10ge: fix error checking and return value in
 myri10ge_allocate_rings
Date: Fri, 09 Mar 2007 11:52:06 -0500
Message-ID: <45F190B6.9060005@garzik.org>
References: <45EF0B6C.9070005@myri.com> <45EF0BA8.3080903@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57801 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767397AbXCIQwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 11:52:08 -0500
In-Reply-To: <45EF0BA8.3080903@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Fix a missing error check in myri10ge_allocate_rings() and set status
> to -ENOMEM before all actual allocations so that the error path returns
> what it should.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |    4 ++++
>  1 file changed, 4 insertions(+)

applied 1-4


