From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.23 1/3]S2IO: Making MSIX as default intr_type
Date: Tue, 07 Aug 2007 18:20:11 -0400
Message-ID: <46B8F01B.1080308@garzik.org>
References: <Pine.GSO.4.10.10708060525530.4004-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44797 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757075AbXHGWUP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 18:20:15 -0400
In-Reply-To: <Pine.GSO.4.10.10708060525530.4004-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sivakumar Subramani wrote:
> - Making MSIX as default intr_type
> - Driver will test MSI-X by issuing test MSI-X vector and if fails it will
>   fallback to INTA
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

This patch series looks a bit big to apply this far past the merge 
window.  It changes behavior in the middle of a -rc stream, which is 
something to avoid since we are deep into "bug fixes only" mode at this 
point.

I'm open to suggestions, otherwise I can apply these to netdev#upstream 
(queued for 2.6.24).

	Jeff


