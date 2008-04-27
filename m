From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] asm/unaligned.h doesn't work well as the very first
	include
Date: Sat, 26 Apr 2008 23:31:28 -0700
Message-ID: <1209277888.14173.45.camel@brick>
References: <20080427051918.GO5882@ZenIV.linux.org.uk>
	 <20080427060944.GB9199@uranus.ravnborg.org>
	 <20080427061210.GT5882@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sam Ravnborg <sam@ravnborg.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:43709 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbYD0GbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 02:31:24 -0400
Received: by wa-out-1112.google.com with SMTP id m16so7075082waf.23
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2008 23:31:23 -0700 (PDT)
In-Reply-To: <20080427061210.GT5882@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-04-27 at 07:12 +0100, Al Viro wrote:
> On Sun, Apr 27, 2008 at 08:09:44AM +0200, Sam Ravnborg wrote:
> 
> > It has been discussed that any .h file should pull
> > in what it needs so the other of includes does not matter.
> > Some do them alphabetically.
> 
> It has been discussed or it has been agreed?  IMO it's a bullshit - especially
> for low-level stuff like that.
> 
> As for the way some do includes...  It's not exactly a family-friendly list,
> but still I'd rather not comment in details on the existing practices...

I'm redoing the unaligned handling in -mm at the moment, and it avoids
this problem.

Harvey

