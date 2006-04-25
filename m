From: Andi Kleen <ak@suse.de>
Subject: Re: determine outgoing interface (eth0,eth1) for a packet according to the dest IP
Date: Tue, 25 Apr 2006 09:43:49 +0200
Message-ID: <200604250943.49422.ak@suse.de>
References: <ada605fb0604250031r2e4a74e7id0b5079fabde9517@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:7327 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1750747AbWDYHn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 03:43:56 -0400
To: "John Que" <qwejohn@gmail.com>
In-Reply-To: <ada605fb0604250031r2e4a74e7id0b5079fabde9517@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 25 April 2006 09:31, John Que wrote:
> Hello,
> What is the right way to determine on which interface card
> (eth0 or eth1) will a packet be sent (according to the dest IP)?

You can send a rtnetlink RTM_GETROUTE message to ask the kernel.
Result is the interface index in RTA_OIF, which can be converted
into a name.

-Andi

