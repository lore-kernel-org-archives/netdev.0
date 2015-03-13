From: Ronald Pina <pinaronald@gmail.com>
Subject: Allow controlling NAPI weight with sysfs
Date: Fri, 13 Mar 2015 21:49:20 +0100
Message-ID: <CAONBAadmkA6sXA7aJU5_LqFOs1iFzE1WoFW5xgoRfBT3rQKGiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: stephen@networkplumber.org
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:33672 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbbCMUtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 16:49:20 -0400
Received: by iecvj10 with SMTP id vj10so121714788iec.0
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 13:49:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

I am working to allow controlling napi weight on kernel 3.18
If may i ask, is it achievable since NAPI interface structure in
current kernels is managed by the driver?

This feature was presented on kernel 2.6.12, here is a patch that can show
 how was that implemented:

http://marc.info/?l=linux-netdev&m=111773621018096&w=2

As soon as on later kernel the weight was inserted on napi_struct, the
weight wasn't exposed any more for every interface wth sysfs.

Please, any help or idea is very appreciated.


Best Regards
