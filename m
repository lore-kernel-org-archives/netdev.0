From: Christoph Lameter <cl@linux.com>
Subject: Kernel sends multicast groups to sockets that did not subscribe to
 the MC group
Date: Mon, 13 Apr 2009 17:06:08 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904131704120.3517@qirst.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:37498 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804AbZDMVVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 17:21:30 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7E02182C108
	for <netdev@vger.kernel.org>; Mon, 13 Apr 2009 17:22:22 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id a948ebfliSXN for <netdev@vger.kernel.org>;
	Mon, 13 Apr 2009 17:22:16 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6B99082C2D6
	for <netdev@vger.kernel.org>; Mon, 13 Apr 2009 17:22:16 -0400 (EDT)
Received: from cl (helo=localhost)
	by qirst.com with local-esmtp (Exim 4.69)
	(envelope-from <cl@linux.com>)
	id 1LtTM0-0005r8-BY
	for netdev@vger.kernel.org; Mon, 13 Apr 2009 17:06:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I ran two processes listening to two multicast groups:

One listening for 239.0.0.51 and the other on 239.0.0.50. Both are
listening on the same port.

If I send a multicast message to 239.0.0.50 then both receive it. Why is
the process listening to 239.0.0.51 receiving the multicast message send
to 239.0.0.50?


