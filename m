From: Wilhelm Wijkander <lists@0x5e.se>
Subject: Re: iproute2 tunnel name parsing
Date: Fri, 18 Sep 2015 01:53:12 +0200
Message-ID: <CAK8ArgOM2Vyr4DJO73wzhgFFbGMm9p+XMGcD2JAWeZ8G+_3PSw@mail.gmail.com>
References: <CAK8ArgO8mWN657smVDuCRHQVKScnBM1K9VP93e-YY+hf2sdwyw@mail.gmail.com>
 <20150917201057.GA32635@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:35262 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418AbbIQXxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 19:53:52 -0400
Received: by ykdu9 with SMTP id u9so32488339ykd.2
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 16:53:52 -0700 (PDT)
In-Reply-To: <20150917201057.GA32635@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the reply Vadim,

2015-09-17 22:10 GMT+02:00 Vadim Kochan <vadim4j@gmail.com>:
> You can use 'name' before 'hel'

Yes, "name" enables me to create the tunnel, things do get trickier
when I'm trying to bring the tunnel device up:

   # ip link set dev hel up
   Usage: ip link add [link DEV] [ name ] NAME
   [snip]
   # ip link set dev name hel up
   Usage: ip link add [link DEV] [ name ] NAME
   [snip]
Adding an address to the tunnel device on the other hand:

   ip addr add 2001:db8:a:a::2/64 dev hel
 is no issue.

Regards,
Wilhelm
