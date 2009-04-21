From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 21 Apr 2009 17:00:52 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904211657500.31780@qirst.com>
References: <1238701718.5669.26.camel@bender>  <alpine.DEB.1.10.0904211131340.21796@qirst.com>  <7e0dd21a0904211313p73143cc8t51b5c537c5edfb05@mail.gmail.com>  <alpine.DEB.1.10.0904211640280.31780@qirst.com>
 <7e0dd21a0904211400l3c9e78e9v70b684702eef89d5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:45310 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754378AbZDUVIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 17:08:55 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E096982C453
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 17:19:19 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MtsD600yxQz0 for <netdev@vger.kernel.org>;
	Tue, 21 Apr 2009 17:19:13 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id CAD9382C280
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 17:19:13 -0400 (EDT)
In-Reply-To: <7e0dd21a0904211400l3c9e78e9v70b684702eef89d5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Apr 2009, Johann Baudy wrote:

> > Duh. So I cannot concurrently operate with multiple threads on the
> > structure.
> Except if you can ensure that multiple threads will not use the same buffer.

Hmmm... Ok.

> > The kernel synchronizes with itself via the socket?
> Not sure to understand?

Doesnt the kernel need some way to synchronize the two
transitions made by the kernel? From "send request" to "sending" and then
to "available"? Otherwise the kernel may set the request to "available"
before the change from "send request" to "sending" is complete.
