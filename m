From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: s390 allmodconfig
Date: Fri, 2 Mar 2007 03:20:05 -0800
Message-ID: <20070302032005.93a36b81.akpm@linux-foundation.org>
References: <20070302001811.b103e2b2.akpm@linux-foundation.org>
	<20070302002512.bd9bbb80.akpm@linux-foundation.org>
	<1172831904.3482.13.camel@johannes.berg>
	<20070302030646.0930d263.akpm@linux-foundation.org>
	<1172833908.3482.20.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>,
	Richard Purdie <rpurdie@rpsys.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:54894 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423030AbXCBLVV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 06:21:21 -0500
In-Reply-To: <1172833908.3482.20.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 02 Mar 2007 12:11:48 +0100 Johannes Berg <johannes@sipsolutions.net> wrote:

> On Fri, 2007-03-02 at 03:06 -0800, Andrew Morton wrote:
> 
> > No, s390 doesn't have PCI.
> 
> Ok.
> 
> > s390 is weird ;)   There's no way it'll support any of the hardware which you're
> > working on (until they release the s390 laptop).  So all we really want to
> > do here is to avoid breaking s390 allmodconfig.
> 
> Alright. I think we'll probably have to make bcm43xx and b44 depend on
> SSB instead of selecting it like the LED trigger stuff below.
> 
> But I don't see why s390 can't include hw random, led trigger or even
> hid, those are all software features afaict.
>  
> 
> > OK, I'll try that, thanks.
> 
> Not that it'll actually help get the compile through... bcm43xx will
> drop fail and bluetooth probably as well.
> 

OK, thanks.

fwiw, http://userweb.kernel.org/~akpm/cross-compilers/ has an s390
cross-compiler binary.

