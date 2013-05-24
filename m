From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next 2/3] xen-netback: switch to per-cpu
 scratch space
Date: Fri, 24 May 2013 13:24:41 +0100
Message-ID: <519F5C09.3030502@citrix.com>
References: <1369391553-16835-1-git-send-email-wei.liu2@citrix.com> <1369391553-16835-3-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<ian.campbell@citrix.com>, <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:43620 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754488Ab3EXMYo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 May 2013 08:24:44 -0400
In-Reply-To: <1369391553-16835-3-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/05/13 11:32, Wei Liu wrote:
> There are maximum nr_onlie_cpus netback threads running. We can make use of
> per-cpu scratch space to reduce the size of buffer space when we move to 1:1
> model.

How much memory does this actually save?  At first glance the savings
don't seem worth it for the extra complexity wrt hotplugged VCPUs etc.

David
