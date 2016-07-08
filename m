From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH v2 4/4] xen-netback: prefer xenbus_scanf()
 over xenbus_gather()
Date: Fri, 8 Jul 2016 17:14:11 +0100
Message-ID: <20160708161411.GC24399@citrix.com>
References: <577FB70002000078000FC9FA@prv-mh.provo.novell.com>
 <577FB8AA02000078000FCA21@prv-mh.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, Juergen Gross <JGross@suse.com>,
	<xen-devel@lists.xenproject.org>, <boris.ostrovsky@oracle.com>,
	<david.vrabel@citrix.com>, <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:2815 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932670AbcGHQOT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2016 12:14:19 -0400
Content-Disposition: inline
In-Reply-To: <577FB8AA02000078000FCA21@prv-mh.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 08, 2016 at 06:28:58AM -0600, Jan Beulich wrote:
> For single items being collected this should be preferred as being more
> typesafe (as the compiler can check format string and to-be-written-to
> variable match) and more efficient (requiring one less parameter to be
> passed).
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>
