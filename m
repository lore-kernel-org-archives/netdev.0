From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net v2 1/3] xen-netback: move NAPI add/remove calls
Date: Fri, 8 Aug 2014 17:52:56 +0100
Message-ID: <20140808165256.GL29341@zion.uk.xensource.com>
References: <1407515833-2550-1-git-send-email-wei.liu2@citrix.com>
 <1407515833-2550-2-git-send-email-wei.liu2@citrix.com>
 <53E4FF86.8040505@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, Ian Campbell <ian.campbell@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:50166 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbaHHQw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 12:52:57 -0400
Content-Disposition: inline
In-Reply-To: <53E4FF86.8040505@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 08, 2014 at 08:49:10PM +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 08/08/2014 08:37 PM, Wei Liu wrote:
> 
> >Originally napi_add was in init_queue and napi_del was in deinit_queue,
> >while kthreads were handled in _connect and _disconnect. Move napi_add
> >and napi_remove
> 
>    netif_napi_{add|del}()?
> 
> > to _connect and _disconnect so that they reside togother
> 
>    Together.
> 

Thanks, I will fix these issues.

Wei.
