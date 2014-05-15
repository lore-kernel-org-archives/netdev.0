From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net] xen-netback: don't move event pointer in TX credit
 timeout callback
Date: Thu, 15 May 2014 12:53:17 +0100
Message-ID: <1400154797.11632.2.camel@kazak.uk.xensource.com>
References: <1400153056-12793-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<jajcus@jajcus.net>, "Paul Durrant" <paul.durrant@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:6929 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751967AbaEOLxT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 07:53:19 -0400
In-Reply-To: <1400153056-12793-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-15 at 12:24 +0100, Wei Liu wrote:
> ... otherwise the frontend will try to send TX event all the time, even
> if no progress can be made. The pointer should only be advanced by the
> routine that actually processes the ring.

Please can you mention that this routing is xenvif_poll.

> Reported-by: Jacek Konieczny <jajcus@jajcus.net>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Other than that small nit:
Acked-by: Ian Campbell <ian.campbell@citrix.com>

Thanks!
