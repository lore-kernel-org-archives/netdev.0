From: Brad Johnson <bjohnson@ecessa.com>
Subject: IFB network driver problems and questions
Date: Mon, 19 Aug 2013 09:35:40 -0500
Message-ID: <52122D3C.2060805@ecessa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:50521 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801Ab3HSOfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 10:35:52 -0400
Received: by mail-oa0-f54.google.com with SMTP id o6so6154281oag.27
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 07:35:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are trying to use the IFB driver for ingress QoS and are having some 
problems getting it to work for us. Even though I have seen it described 
as a replacement for IMQ, it appears that it hooks the packets before 
netfilter and so marks set with iptables are not seen by tc filters on 
the ifb device. This makes it difficult, and in some cases impossible, 
to do any kind of complex filtering, such as port ranges and many other 
matches that are easy to do with iptables. So my questions are:
1. Is there any way to set marks with iptables and have them seen in the 
IFB device?
2. Is there any way to use IFB as an iptables target the same way you 
can do a "-j IMQ" target?
3. If the previous answers are 'no', then are there any plans to 
implement those features?

Thanks
