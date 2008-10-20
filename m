From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tcp_sack problem Re: [Bug 11721] after upgrade to 2.6.27 i cannot
 navigate
Date: Tue, 21 Oct 2008 00:04:45 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810202356280.30254@wrl-59.cs.helsinki.fi>
References: <bug-11721-11547@http.bugzilla.kernel.org/>
 <20081018202056.F1933108040@picon.linux-foundation.org>
 <20081018210252.GA6048@ami.dom.local> <20081018215007.GB6048@ami.dom.local>
 <Pine.LNX.4.64.0810201106200.7072@wrl-59.cs.helsinki.fi> <20081020225524.7a7c5d48@topolino>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: Aldo Maggi <sentiniate@tiscali.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59794 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166AbYJTVEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 17:04:47 -0400
In-Reply-To: <20081020225524.7a7c5d48@topolino>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In general, please use reply to all when dealing with linux developers (so 
that related people & lists end up being cc'ed), we just work that way :-).
I did restore CCs for you this time.

On Mon, 20 Oct 2008, Aldo Maggi wrote:

> bear with me but i do not wish to create problems to you all, therefore
> i'd like to be sure to be doing the correct procedure before going on
> with the compilation:
> 
> i've used your patch with the sources of kernel 2.6.27-rc1 which i had
> already patched vith git1 because of problems with the compilation
> (problems which had been solved with git1 patch).
> 
> what follows is the output of patch, is it correct?
> 
> paperino:/usr/src/linux-2.6.27-rc1-git1# patch -p1 < ../patch_iarno
> patching file net/ipv4/tcp_output.c
> Hunk #1 succeeded at 371 (offset -5 lines).
> Hunk #2 succeeded at 393 (offset -5 lines).

-5 offset might well happen and patch was able to apply it right 
regardless of that (I might have had some unrelated modifications 
or so in my local dev tree which causes the line numbers to shift
a bit).

> i'll anyway go on with the compilation, but i don't want that you
> expect i do something and i do something else! :-D

I'm fine with the kernel and your procedure... :-) And also 2.6.27 won't 
make much difference to 2.6.27-rc-something I think, so you can ignore 
Jarek's suggestion to use 2.6.27+patch if you feel -rc is easier for you 
now that you've started with it. I'm fine with either kernel 
version+patch.

-- 
 i.
