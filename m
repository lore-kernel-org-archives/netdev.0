From: Johann Baudy <johann.baudy@gnu-log.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 21 Apr 2009 23:05:27 +0200
Message-ID: <7e0dd21a0904211405h488cbbc0j4e5c197789cc28ae@mail.gmail.com>
References: <1238701718.5669.26.camel@bender>
	 <alpine.DEB.1.10.0904211131340.21796@qirst.com>
	 <7e0dd21a0904211313p73143cc8t51b5c537c5edfb05@mail.gmail.com>
	 <7e0dd21a0904211346p523b1e1fo7f8ec7bd18ad87cf@mail.gmail.com>
	 <alpine.DEB.1.10.0904211642320.31780@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:63024 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755878AbZDUVF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 17:05:29 -0400
Received: by fxm2 with SMTP id 2so2750764fxm.37
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 14:05:27 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.10.0904211642320.31780@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Well yes. But I guess you know best what to call them. Just make them
> more decriptive of their function.

Yes, I understand, but I'm just afraid of backward compatibility with
libraries that are currently using packet_mmap for RX ring. If I
rename those TP_STATUS_KERNEL into TP_STATUS_AVAILABLE. I will break
this compatibility.
(for compilation).
