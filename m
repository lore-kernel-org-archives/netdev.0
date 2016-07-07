From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: prefer xenbus_write()
 over xenbus_printf() where possible
Date: Thu, 07 Jul 2016 06:05:31 -0600
Message-ID: <577E61AB02000078000FC318@prv-mh.provo.novell.com>
References: <577E282002000078000FBECB@prv-mh.provo.novell.com>
 <577E3918.5030303@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <david.vrabel@citrix.com>,
	"xen-devel" <xen-devel@lists.xenproject.org>,
	"Juergen Gross" <JGross@suse.com>, <netdev@vger.kernel.org>
To: <boris.ostrovsky@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prv-mh.provo.novell.com ([137.65.248.74]:46569 "EHLO
	prv-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbcGGMFc convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:5:1>);
	Thu, 7 Jul 2016 08:05:32 -0400
In-Reply-To: <577E3918.5030303@citrix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 07.07.16 at 13:12, <david.vrabel@citrix.com> wrote:
> The better clean-up is to remove xenbus_write() in favour of
> xenbus_printf() everywhere (especially since one of your "cleanups" made
> it worse).

I don't think I've seen any reply indicating something has got made
worse. The fact that in one case I left the xenbus_printf() in place
despite having replaced the format string by one without %
specifier didn't result in a bug at all.

> xenbus_printf() does everything xenbus_write() can do with no loss of
> readability.

Yet with quite a bit higher overhead. Readability is not the point here.

Jan
