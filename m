From: David Miller <davem@davemloft.net>
Subject: Re: the mystery that is sock_fasync
Date: Fri, 11 Aug 2006 03:31:11 -0700 (PDT)
Message-ID: <20060811.033111.94752204.davem@davemloft.net>
References: <20060811.031516.38316536.davem@davemloft.net>
	<20060811102820.GA10816@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:34951
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932097AbWHKKbB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 06:31:01 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060811102820.GA10816@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 11 Aug 2006 14:28:20 +0400

> On Fri, Aug 11, 2006 at 03:15:16AM -0700, David Miller (davem@davemloft.net) wrote:
> > Did I miss some way that multiple file objects can point to the
> > same socket inode?
> 
> What about dup and pipe?

Dup makes new "file descriptor" references to the file object.

It does not create a new file object reference to a socket inode,
which is what we're concerned with here.

Pipe files do not point to socket inodes.
