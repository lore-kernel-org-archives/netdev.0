From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netfront: correct MAX_TX_TARGET calculation.
Date: Fri, 27 Jan 2012 10:36:29 +0000
Message-ID: <1327660589.2585.14.camel@leeni.uk.xensource.com>
References: <1327598603-16398-1-git-send-email-wei.liu2@citrix.com>
	 <20120126181900.GB25572@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeremy@goop.org" <jeremy@goop.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:32562 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758Ab2A0Kgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 05:36:31 -0500
In-Reply-To: <20120126181900.GB25572@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-01-26 at 18:19 +0000, Konrad Rzeszutek Wilk wrote:
> On Thu, Jan 26, 2012 at 05:23:23PM +0000, Wei Liu wrote:
> 
> Can you give some more details please? What is the impact of
> not having this? Should it be backported to stable?
> 

I think it will not cause crash, only the scratch space size is
affected, thus impacting tx batching a bit.

As the tx structure is bigger than rx structure. I think scratch space
size is likely to shrink after correction.


Wei.
