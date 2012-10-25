From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Disable tcp MSS option in three way handshake?
Date: Thu, 25 Oct 2012 15:27:54 -0700
Message-ID: <CAK3+h2xKHBNXzY0WNwPV+oGbY00UVfJpO-qjFW2cxCpmdt+hAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:54879 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683Ab2JYW1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 18:27:54 -0400
Received: by mail-ia0-f174.google.com with SMTP id y32so1712974iag.19
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 15:27:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this sounds crazy, we have a weird situation that an unknown tcp
implementation not putting tcp MSS option in the SYN/ACK which caused
us some issue. I am tasked to mimic the unknown tcp immplementation on
not sending MSS in tcp SYN/ACK, I am wondering if I can achieve that
by modifying linux kernel tcp code,  there is socket option
TCP_MAXSEG, but that seems only affecting the size of MSS, not
removing the MSS option. do you have any pointer on how to do that in
kernel tcp code?

Thanks

Vincent
