From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [PATCH 09/15] [TCP]: Introduce tcp_hdrlen() and tcp_optlen()
Date: Tue, 13 Mar 2007 16:57:26 -0700
Message-ID: <4807377b0703131657o35f0a307jb069f4555db6338d@mail.gmail.com>
References: <39e6f6c70703131446r3341c6c0i2a8168fdfcbde868@mail.gmail.com>
	 <4807377b0703131622w5dde4304v63fd941f74719a27@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"Netdev List" <netdev@vger.kernel.org>
To: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.228]:29411 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649AbXCMX52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2007 19:57:28 -0400
Received: by wr-out-0506.google.com with SMTP id i28so1567422wra
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2007 16:57:27 -0700 (PDT)
In-Reply-To: <4807377b0703131622w5dde4304v63fd941f74719a27@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/13/07, Jesse Brandeburg <jesse.brandeburg@gmail.com> wrote:
> acme, good stuff, but does the " * 4" generate equivalent assembly
> with gcc 3/4 as " << 2" ?
>
> I could assume that the compiler would be smart enough, but every time
> I assume I know what the compiler is doing I get myself in trouble.

nevermind, I wrote a program myself to test it (which I should have
done first).  with x86-64 gcc 3.4.6 or 4.1.0 it always comes out to
shl 2, %eax

etc, sorry for the noise.
