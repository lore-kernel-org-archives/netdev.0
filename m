From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH resend] rewrite AF_UNIX garbage collector, fixes race
Date: Tue, 10 Jul 2007 22:25:11 -0700
Message-ID: <20070710222511.bcc87825.akpm@linux-foundation.org>
References: <E1I61UT-0006Gk-00@dorka.pomaz.szeredi.hu>
	<20070710.221224.48800386.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: miklos@szeredi.hu, netdev@vger.kernel.org, ebiederm@xmission.com,
	viro@ftp.linux.org.uk, alan@lxorguk.ukuu.org.uk,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47943 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752675AbXGKF0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 01:26:04 -0400
In-Reply-To: <20070710.221224.48800386.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Jul 2007 22:12:24 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> But myself, nor any other developers, are going to review your work
> any faster if you do things like try to slip things in behind the
> maintainer's back as you attempted to do yesterday by asking Andrew to
> put your AF_UNIX garbage collector rewrite directly into his -mm tree.

mmm...  I didn't see it as a slip-behind-the-back thing.  More a "park it
in -mm for a bit of concurrent testing and so it doesn't get lost and so I
don't have to worry about it any more" thing.  Plenty of that goes on.

It wasn't done in a very subtle way though ;)
