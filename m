From: "Philip Stark" <heller.barde@gmail.com>
Subject: Re: 2.6.27 seems to break something with DSL
Date: Wed, 22 Oct 2008 00:28:40 +0200
Message-ID: <c6740f810810211528g641b3224j3a70ee4b56942bb9@mail.gmail.com>
References: <c6740f810810110553q75478033ub984651d5509199b@mail.gmail.com>
	 <20081020101241.456963cd@doriath.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.186]:16049 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461AbYJUW2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 18:28:42 -0400
Received: by fk-out-0910.google.com with SMTP id 18so2734648fkq.5
        for <netdev@vger.kernel.org>; Tue, 21 Oct 2008 15:28:40 -0700 (PDT)
In-Reply-To: <20081020101241.456963cd@doriath.conectiva>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was just going to say that Bug Nr. 11721 on bugzilla.kernel.org is
exactly my problem and is in fact resolved with the
solution/workaround presented there.

Thanks for your time
Philip Stark

2008/10/20 Luiz Fernando N. Capitulino <lcapitulino@mandriva.com.br>:
<snip>
> | it seems to  be related to the packet  size because ping only seems to
> | work because it uses small packets. if i increase the ping size up to
> | 1000 bytes, it fails as well. (while it does work on 2.6.26)
>
>  If you haven't solved this issue yet you could try:
>
> # echo 0 > /proc/sys/net/ipv4/tcp_timestamps
>
>  We (Mandriva) have had some reports of this issue and it seems that
> some broken routers can drop packages because of the timestamp (that's
> what our local network guy has said). Disabling timestamps make it work
> again.
>
> --
> Luiz Fernando N. Capitulino
>
