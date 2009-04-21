From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 21 Apr 2009 17:08:50 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904211708290.15595@qirst.com>
References: <1238701718.5669.26.camel@bender>  <alpine.DEB.1.10.0904211131340.21796@qirst.com>  <7e0dd21a0904211313p73143cc8t51b5c537c5edfb05@mail.gmail.com>  <7e0dd21a0904211346p523b1e1fo7f8ec7bd18ad87cf@mail.gmail.com>  <alpine.DEB.1.10.0904211642320.31780@qirst.com>
 <7e0dd21a0904211405h488cbbc0j4e5c197789cc28ae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:58241 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756159AbZDUVQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 17:16:57 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2ED8C82C704
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 17:27:22 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id LBkVSrMH4N4c for <netdev@vger.kernel.org>;
	Tue, 21 Apr 2009 17:27:16 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1AED882C6DB
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 17:27:16 -0400 (EDT)
In-Reply-To: <7e0dd21a0904211405h488cbbc0j4e5c197789cc28ae@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Apr 2009, Johann Baudy wrote:

> > Well yes. But I guess you know best what to call them. Just make them
> > more decriptive of their function.
>
> Yes, I understand, but I'm just afraid of backward compatibility with
> libraries that are currently using packet_mmap for RX ring. If I
> rename those TP_STATUS_KERNEL into TP_STATUS_AVAILABLE. I will break
> this compatibility.
> (for compilation).

You can do

#define TP_STATUS_AVAILABLE TP_STATUS_KERNEL

