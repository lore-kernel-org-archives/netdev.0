From: Wei Liu <liuw@liuw.name>
Subject: Re: [Xen-devel] [PATCH net-next V3 2/3] xen-netfront: split event
 channels support for Xen frontend driver
Date: Wed, 22 May 2013 21:20:37 +0100
Message-ID: <CAOsiSVXptBRRA=m3HFnO7eQWjxN_wgfzAcvw+rPebOPH9mRjXg@mail.gmail.com>
References: <1369240487-18834-1-git-send-email-wei.liu2@citrix.com>
 <1369240487-18834-3-git-send-email-wei.liu2@citrix.com> <519D1D61.8030500@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	David Vrabel <david.vrabel@citrix.com>, jbeulich@suse.com
To: annie li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:59618 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753849Ab3EVUVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 16:21:09 -0400
Received: by mail-we0-f176.google.com with SMTP id p58so1553646wes.21
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 13:21:07 -0700 (PDT)
In-Reply-To: <519D1D61.8030500@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 22, 2013 at 8:32 PM, annie li <annie.li@oracle.com> wrote:
>
>
> Originally, netfront protects access to rx shared-ring with tx_lock, you
> remove this protection here. It is better to protect the ring access by a
> sperate rx_lock then.
>

TX ring and RX ring are separate rings. I don't think that comment / code
makes sense any more. My stress test confirms that.


Wei.

> Thanks
> Annie
>
>
>
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
