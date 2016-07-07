From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: prefer xenbus_write() over
 xenbus_printf() where possible
Date: Thu, 7 Jul 2016 12:12:24 +0100
Message-ID: <577E3918.5030303@citrix.com>
References: <577E282002000078000FBECB@prv-mh.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: xen-devel <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>, <david.vrabel@citrix.com>,
	<boris.ostrovsky@oracle.com>, Juergen Gross <JGross@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:29779 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbcGGLM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 07:12:27 -0400
In-Reply-To: <577E282002000078000FBECB@prv-mh.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07/16 09:00, Jan Beulich wrote:
> ... as being the simpler variant.

It's really annoying that all these related cleanups where not in the
same thread. Don't do this again, please.

The better clean-up is to remove xenbus_write() in favour of
xenbus_printf() everywhere (especially since one of your "cleanups" made
it worse).

xenbus_printf() does everything xenbus_write() can do with no loss of
readability.

David
