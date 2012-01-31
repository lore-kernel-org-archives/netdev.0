From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH V3 10/16] netback: rework of per-cpu scratch space.
Date: Tue, 31 Jan 2012 10:43:40 +0000
Message-ID: <1328006620.5553.59.camel@leeds.uk.xensource.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
	 <1327934734-8908-11-git-send-email-wei.liu2@citrix.com>
	 <CAL4WiirrQ+2PqojQ9dnGRF16cxx-1QNRWqcMkVqqZSZwvWC58Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"Ian Campbell" <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:52616 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274Ab2AaKns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 05:43:48 -0500
In-Reply-To: <CAL4WiirrQ+2PqojQ9dnGRF16cxx-1QNRWqcMkVqqZSZwvWC58Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-31 at 01:25 +0000, Eric Dumazet wrote:
> 
> Problem is you lost NUMA awareness here.
> 
> Please check vzalloc_node()

Good point, thanks.

Wei.
