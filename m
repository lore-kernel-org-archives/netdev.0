From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] gianfar: fix handle errors returned by platform_get_irq*()
Date: Tue, 21 Oct 2008 01:15:08 -0400
Message-ID: <48FD655C.6060608@garzik.org>
References: <48FD6A26.9010000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org
To: roel kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53342 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751455AbYJUFPN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 01:15:13 -0400
In-Reply-To: <48FD6A26.9010000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

roel kluin wrote:
> platform_get_irq*() returns on -ENXIO when the resource cannot be
> found, but this remains unnoticed if stored in an unsigned.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> since commit 489447380a2921ec0e9154f773c44ab3167ede4b

applied


