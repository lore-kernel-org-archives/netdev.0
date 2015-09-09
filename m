From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH net v2 2/2] xen-netfront: respect user provided max_queues
Date: Wed, 9 Sep 2015 11:24:20 +0100
Message-ID: <55F008D4.2090304@citrix.com>
References: <1441794186-26991-1-git-send-email-wei.liu2@citrix.com>
 <1441794186-26991-3-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: Wei Liu <wei.liu2@citrix.com>,
	Xen-devel <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:25178 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752903AbbIIKYX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2015 06:24:23 -0400
In-Reply-To: <1441794186-26991-3-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/15 11:23, Wei Liu wrote:
> Originally that parameter was always reset to num_online_cpus during
> module initialisation, which renders it useless.
> 
> The fix is to only set max_queues to num_online_cpus when user has not
> provided a value.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

Thanks.

David
