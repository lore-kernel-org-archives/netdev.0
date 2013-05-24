From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next 2/3] xen-netback: switch to per-cpu
 scratch space
Date: Fri, 24 May 2013 13:31:30 +0100
Message-ID: <20130524123130.GB16745@zion.uk.xensource.com>
References: <1369391553-16835-1-git-send-email-wei.liu2@citrix.com>
 <1369391553-16835-3-git-send-email-wei.liu2@citrix.com>
 <519F5C09.3030502@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <ian.campbell@citrix.com>,
	<konrad.wilk@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:3645 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753341Ab3EXMbc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 May 2013 08:31:32 -0400
Content-Disposition: inline
In-Reply-To: <519F5C09.3030502@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 24, 2013 at 01:24:41PM +0100, David Vrabel wrote:
> On 24/05/13 11:32, Wei Liu wrote:
> > There are maximum nr_onlie_cpus netback threads running. We can make use of
> > per-cpu scratch space to reduce the size of buffer space when we move to 1:1
> > model.
> 
> How much memory does this actually save?  At first glance the savings
> don't seem worth it for the extra complexity wrt hotplugged VCPUs etc.
> 

It would not save any for the old model netback. But if we switch to 1:1
model the saving depends on how many vifs you run.

This can be calculated by:
(nr_vifs - nr_cpus) * sizeof(scratch space)


Wei.

> David
