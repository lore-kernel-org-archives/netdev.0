From: Johann Baudy <johann.baudy@gnu-log.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 21 Apr 2009 23:00:51 +0200
Message-ID: <7e0dd21a0904211400l3c9e78e9v70b684702eef89d5@mail.gmail.com>
References: <1238701718.5669.26.camel@bender>
	 <alpine.DEB.1.10.0904211131340.21796@qirst.com>
	 <7e0dd21a0904211313p73143cc8t51b5c537c5edfb05@mail.gmail.com>
	 <alpine.DEB.1.10.0904211640280.31780@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f163.google.com ([209.85.218.163]:63596 "EHLO
	mail-bw0-f163.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440AbZDUVAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 17:00:53 -0400
Received: by bwz7 with SMTP id 7so1985641bwz.37
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 14:00:51 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.10.0904211640280.31780@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Duh. So I cannot concurrently operate with multiple threads on the
> structure.
Except if you can ensure that multiple threads will not use the same buffer.

> The kernel synchronizes with itself via the socket?
Not sure to understand?
Both below rules + cache/mem flushing synchronize User and Kernel spaces
TP_STATUS_KERNEL => TP_STATUS_SEND_REQUEST: only performed by user.
TP_STATUS_SENDING => TP_STATUS_KERNEL  only performed by kernel.
