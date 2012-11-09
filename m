From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: How to compile tcp fast open client app with kernel tfo client
 support ?
Date: Fri, 9 Nov 2012 10:23:12 -0800
Message-ID: <CAGK4HS-U+Ov5x8z+1CRZdiAD9MhfBUfurKKBbt1EWGYFLN8TcA@mail.gmail.com>
References: <CAK3+h2xmgy+RhUy=MZ5Cu8Zpz+gQmt3dXCX0tpLAWFCTeujBLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:33159 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753997Ab2KISXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 13:23:13 -0500
Received: by mail-oa0-f46.google.com with SMTP id h16so4329659oag.19
        for <netdev@vger.kernel.org>; Fri, 09 Nov 2012 10:23:12 -0800 (PST)
In-Reply-To: <CAK3+h2xmgy+RhUy=MZ5Cu8Zpz+gQmt3dXCX0tpLAWFCTeujBLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> htmlgettfo.c: In function 'get_page_thread':
> htmlgettfo.c:109: error: 'MSG_FASTOPEN' undeclared (first use in this function)
> htmlgettfo.c:109: error: (Each undeclared identifier is reported only once
> htmlgettfo.c:109: error: for each function it appears in.)
>
> I have the 3.6.0 kernel header file package installed
> /usr/src/linux-headers-3.6.0-custom, the user space include file
> /usr/include/linux is original one coming with 10.0.4 distro kernel
>
> I am suspecting I don't have proper linux header file that has
> MSG_FASTOPEN declared in user space. can anyone shed a light on how to
> get MSG_FASTOPEN supported and compiled in client code properly?
>

Vincent ,
You can try adding the following to the client code.

#define MSG_FASTOPEN    0x20000000

This is missing still from user space header files I presume.

Vijay
