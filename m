From: Jason Cassell <bluesloth600@gmail.com>
Subject: Re: [Bugme-new] [Bug 11855] New: kernel BUG when bringing down ppp
	connection
Date: Wed, 29 Oct 2008 04:16:02 -0700
Message-ID: <1225278962.31934.15.camel@kagome>
References: <bug-11855-10286@http.bugzilla.kernel.org/>
	 <20081027202407.7e390191.akpm@linux-foundation.org>
	 <20081028094456.2cfc32ac@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:28810 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753841AbYJ2LQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 07:16:14 -0400
Received: by yw-out-2324.google.com with SMTP id 9so771637ywe.1
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 04:16:13 -0700 (PDT)
In-Reply-To: <20081028094456.2cfc32ac@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-10-28 at 09:44 +0000, Alan Cox wrote:
> 
> Ldisc refcount went negative. Will take a look at the bug report when I
> have time. First guess would be a bug in the specific USB serial driver -
> so need to know which driver is handlign the 26-183 

pl2303

> and what is loaded
> (an lsmod would be handy)

the "Modules linked in" list is in the screen photos.  I'll go get some
real lsmod output if that's not enough.

Jason Cassell

