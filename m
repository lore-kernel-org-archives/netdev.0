From: Wilhelm Wijkander <lists@0x5e.se>
Subject: iproute2 tunnel name parsing
Date: Thu, 17 Sep 2015 21:55:29 +0200
Message-ID: <CAK8ArgO8mWN657smVDuCRHQVKScnBM1K9VP93e-YY+hf2sdwyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:35102 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbbIQT4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 15:56:09 -0400
Received: by ykdu9 with SMTP id u9so27564722ykd.2
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 12:56:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to create a sit tunnel called "hel": ip tun add hel mode
sit remote 10.200.0.2 local 10.200.1.2 ttl 255, however it seems like
this is interpreted as the help argument and I get the usage text. Is
there a way to escape names that I've missed, or is this an error
somewhere in argv parsing?

(I'm not subscribed, so a cc would be appreciated)
Thanks,
Wilhelm
