From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen-netback: fixing the propagation of the transmit
 shaper timeout
Date: Tue, 6 Jan 2015 15:54:07 +0000
Message-ID: <1420559647.28863.174.camel@citrix.com>
References: <1420559084-28370-1-git-send-email-imrep.amz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>, <linux-kernel@vger.kernel.org>,
	"Palik, Imre" <imrep@amazon.de>,
	Anthony Liguori <aliguori@amazon.com>
To: Imre Palik <imrep.amz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:57573 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756291AbbAFPyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 10:54:12 -0500
In-Reply-To: <1420559084-28370-1-git-send-email-imrep.amz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-01-06 at 16:44 +0100, Imre Palik wrote:
> From: "Palik, Imre" <imrep@amazon.de>
> 
> Since e9ce7cb6b107 ("xen-netback: Factor queue-specific data into queue struct"),
> the transimt shaper timeout is always set to 0.  The value the user sets via
> xenbus is never propagated to the transmit shaper.
> 
> This patch fixes the issue.
> 
> Cc: Anthony Liguori <aliguori@amazon.com>
> Signed-off-by: Imre Palik <imrep@amazon.de>

Acked-by: Ian Campbell <ian.campbell@citrix.com>
