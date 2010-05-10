From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: bluetooth-next-2.6 2010-05-10
Date: Mon, 10 May 2010 04:20:31 -0700 (PDT)
Message-ID: <20100510.042031.135962157.davem@davemloft.net>
References: <cover.1273484094.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55664
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753871Ab0EJLUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 07:20:24 -0400
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok, I pulled this.

But patch #32 needs to be fixed.  That TX window thing is, if
anything, a socket option not some obscure module load parameter.

Doing it with a module parameter means that you can't make it so that
only some sockets (or some network paths) use a certain TX window
value and other's not.

Another alternative is to, as implied, make it a route metric or
similar.

Anything but a module option is appropriate for this.

