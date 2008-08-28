From: "Tobias Koeck" <tobias.koeck@gmail.com>
Subject: Re: Questions about Linux kernel network programming
Date: Thu, 28 Aug 2008 17:03:14 +0200
Message-ID: <379e30200808280803j6a2a86bfya34ecc17127a1bbd@mail.gmail.com>
References: <3fedcc3b0808280733w1d7b24dgf95540d2078856f8@mail.gmail.com>
	 <3fedcc3b0808280748q4090c5e7n45c74c4fd3b42cca@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Thiago Lacerda" <thiagotbl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:57228 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752746AbYH1PDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 11:03:16 -0400
Received: by fg-out-1718.google.com with SMTP id 19so278218fgg.17
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2008 08:03:14 -0700 (PDT)
In-Reply-To: <3fedcc3b0808280748q4090c5e7n45c74c4fd3b42cca@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Of course you can code a netfilter target extension module. Changing
the main kernel network code directly is not necessairy.

Check out the pdf for writing such modules under

http://jengelh.medozas.de/

Check out the
Greetings
t.

On Thu, Aug 28, 2008 at 4:48 PM, Thiago Lacerda <thiagotbl@gmail.com> wrote:
> Hi everyone, I'm a Computer Science student from Brazil.
>
> Hope that you can help me with my undergraduate conclusion project.
>
> I have to capture packets at kernel level. More specifically, I have
> to write a kernel module (for kernel 2.6) that access all the packets
> that are coming through my network interface, then perform some
> operations on that packets and then decide if they can go to user land
> or not.
>
> Please note that I can't do it as a firewall, because I can't
> interfere on the  applications that  work with network. My kernel
> module will get communicated with traffic classifier, that will be
> executing at user land and will inspect the packets that the module
> passed to it.
>
> Can you help me on how can I develop it?
>
> Thanks in advance
>
> Best regards
>
>
> --
> Thiago de Barros Lacerda
> Computer Science Undergraduate Student - CIn/UFPE - 2004.2
> Researcher/Software Developer - GPRT - Networking and
> Telecommunications Research Group
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
