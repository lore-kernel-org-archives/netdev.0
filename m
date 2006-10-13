From: Jan Dittmer <jdi@l4x.org>
Subject: Re: [PATCH 01/02 V3] net/ipv6: seperate sit driver to extra module
Date: Sat, 14 Oct 2006 01:09:39 +0200
Message-ID: <45301CB3.4060803@l4x.org>
References: <20061010153745.GA27455@zlug.org>	<452FD6F6.3090907@l4x.org>	<20061013191744.GA30089@zlug.org> <20061013.150608.63128976.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: joro-lkml@zlug.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.trixing.net ([87.230.125.58]:58842 "EHLO mail.trixing.net")
	by vger.kernel.org with ESMTP id S1751977AbWJMXKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2006 19:10:09 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061013.150608.63128976.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Joerg Roedel <joro-lkml@zlug.org>
> Date: Fri, 13 Oct 2006 21:17:45 +0200
> 
>> On Fri, Oct 13, 2006 at 08:12:06PM +0200, Jan Dittmer wrote:
>>> This is missing the MODULE_LICENSE statements and taints the kernel upon
>>> loading. License is obvious from the beginning of the file.
>  ...
>>> Signed-off-by: Jan Dittmer <jdi@l4x.org>
>> Signed-off-by: Joerg Roedel <joro-lkml@zlug.org>
> 
> Applied, thanks for catching this Jan.
> 

Btw. is there any way to autoload the sit module or is this the
task of the distribution tools? Debian etch at least does not
automatically probe the module when trying to bring up a 6to4 tunnel.

Jan
