From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Connecting to sockets on MNT_READONLY mounts?
Date: Thu, 1 May 2014 23:34:32 +0100
Message-ID: <20140501223432.GD18016@ZenIV.linux.org.uk>
References: <CALCETrUXbS4BMWMd0XXgFqyvmpu+WML840_mzbPiov8WmaA=Xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:57721 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044AbaEAWed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 18:34:33 -0400
Content-Disposition: inline
In-Reply-To: <CALCETrUXbS4BMWMd0XXgFqyvmpu+WML840_mzbPiov8WmaA=Xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 01, 2014 at 03:20:00PM -0700, Andy Lutomirski wrote:
> Is it supposed to work?

Why the hell not?  Same as opening a device node on r/o filesystem for
write, or doing the same with FIFO.
