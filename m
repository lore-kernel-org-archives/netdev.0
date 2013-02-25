From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/pasemi: Fix missing coding style
Date: Sun, 24 Feb 2013 17:23:29 -0800
Message-ID: <1361755409.2281.9.camel@joe-AO722>
References: <1361746879-29261-1-git-send-email-s.syam@samsung.com>
	 <20130224.201301.457851300548359313.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: syamsidhardh@gmail.com, netdev@vger.kernel.org, olof@lixom.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:55272 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759456Ab3BYBXg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Feb 2013 20:23:36 -0500
In-Reply-To: <20130224.201301.457851300548359313.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-02-24 at 20:13 -0500, David Miller wrote:
> From: Syam Sidhardhan <syamsidhardh@gmail.com>
> Date: Mon, 25 Feb 2013 04:31:19 +0530
> 
> > -             } else
> > +             } else {
> >                       freed = 2;
> > +             }
> 
> Single line statements do not need braces.

I guess you didn't see the preceding block with braces.

CodingStyle:

This does not apply if only one branch of a conditional statement is a single
statement; in the latter case use braces in both branches:
