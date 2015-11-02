From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 2/5] dp83640: Delay scheduled work.
Date: Mon, 2 Nov 2015 10:59:47 +0100
Message-ID: <20151102095947.GA3291@netboy>
References: <1446207244-2206-1-git-send-email-stefan.sorensen@spectralink.com>
 <1446207244-2206-3-git-send-email-stefan.sorensen@spectralink.com>
 <20151030203729.GC27879@netboy>
 <1446448990.2437.7.camel@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?iso-8859-1?B?U/hyZW5zZW4s?= Stefan
	<Stefan.Sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37000 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbbKBJ7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 04:59:52 -0500
Received: by wmff134 with SMTP id f134so55548372wmf.0
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 01:59:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1446448990.2437.7.camel@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 02, 2015 at 07:23:12AM +0000, S=F8rensen, Stefan wrote:
> The workqueue is only used for delivering packets where the timestamp
> was lost - if a timestamp is received, the packet is delivered
> immediately. This patch may introduce a slight delay of the packets
> where the timestamp never arrives, by these packets are properly not
> very useful to the application anyway.

Ok, thanks for the explanation.  I mixed this up with another out of
tree driver that I was hacking recently.

Acked-by: Richard Cochran <richardcochran@gmail.com>
