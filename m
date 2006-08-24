From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: TCP ACK
Date: Thu, 24 Aug 2006 10:16:42 -0700
Message-ID: <20060824101642.05f68718@localhost.localdomain>
References: <F444CAE5E62A714C9F45AA292785BED30EB97453@esng11p33001.sg.csfb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12508 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030399AbWHXRQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 13:16:56 -0400
To: "Majumder, Rajib" <rajib.majumder@credit-suisse.com>
In-Reply-To: <F444CAE5E62A714C9F45AA292785BED30EB97453@esng11p33001.sg.csfb.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 24 Aug 2006 23:03:22 +0800
"Majumder, Rajib" <rajib.majumder@credit-suisse.com> wrote:

> Hi,
> 
> I had a fundamental question regarding stack. When does TCP ack a segment? Is it immediately receiving a segment or after copying the data from kernel to user i.e after read() system call returns?
> 
> Any input is highly appreciated. 
> 
> Thanks
> 
> Rajib
> 

TCP ack's when segment is received and placed in the socket buffer.
For questions like this, you are better off looking at traditional unix
network programming books

	http://www.thefreecountry.com/documentation/unixbooks.shtml

-- 
Stephen Hemminger <shemminger@osdl.org>

All non-trivial abstractions, to some degree, are leaky.
