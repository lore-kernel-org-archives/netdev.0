From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH V4 7/7] xen-netback: don't disconnect frontend when
 seeing oversize packet
Date: Fri, 12 Apr 2013 16:38:27 +0100
Message-ID: <1365781107.15783.98.camel@zakaz.uk.xensource.com>
References: <1365776646-10796-1-git-send-email-wei.liu2@citrix.com>
	 <1365776646-10796-8-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"jbeulich@suse.com" <jbeulich@suse.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:7417 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752591Ab3DLPia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 11:38:30 -0400
In-Reply-To: <1365776646-10796-8-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-12 at 15:24 +0100, Wei Liu wrote:
> Some frontend drivers are sending packets > 64 KiB in length. This length
> overflows the length field in the first slot making the following slots have
> an invalid length.
> 
> Turn this error back into a non-fatal error by dropping the packet. To avoid
> having the following slots having fatal errors, consume all slots in the
> packet.
> 
> This does not reopen the security hole in XSA-39 as if the packet as an
> invalid number of slots it will still hit fatal error case.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>
