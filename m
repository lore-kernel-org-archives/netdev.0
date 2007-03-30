From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.21-rc5-mm3: fix e1000 compilation
Date: Fri, 30 Mar 2007 10:01:04 -0700
Message-ID: <20070330100104.9b770cd8.akpm@linux-foundation.org>
References: <20070330085029.GA6556@localhost.sw.ru>
	<460D2108.1080101@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@sw.ru>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:41901 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753930AbXC3RBt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 13:01:49 -0400
In-Reply-To: <460D2108.1080101@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Mar 2007 07:39:04 -0700 "Kok, Auke" <auke-jan.h.kok@intel.com> wrote:

> Alexey Dobriyan wrote:
> >   CC [M]  drivers/net/e1000/e1000_main.o
> > drivers/net/e1000/e1000_main.c: In function 'e1000_tso':
> > drivers/net/e1000/e1000_main.c:2968: error: dereferencing pointer to incomplete type
> > 	...
> > 
> 
> can you send me your config? I'd like to see why nobody here didn't spot this on 
> any of our tests.
> 

test.kernel.org got thoroughly broken by e1000, but Alexey's patch fixed things
up.
