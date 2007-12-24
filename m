From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] skge csum problems
Date: Mon, 24 Dec 2007 14:15:40 +0100
Message-ID: <p73sl1sp72b.fsf@bingen.suse.de>
References: <20071224094352.GU8181@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33403 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751780AbXLXNPm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Dec 2007 08:15:42 -0500
In-Reply-To: <20071224094352.GU8181@ftp.linux.org.uk> (Al Viro's message of "Mon\, 24 Dec 2007 09\:43\:52 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al Viro <viro@ftp.linux.org.uk> writes:
>
> Checksum is fixed-endian and we want it that way; IOW, what we end up
> storing in skb->csum should be fixed-endian as well.

AFAIK skb->csum is always native endian because it normally
needs to be manipulated further even for RX.

-Andi
