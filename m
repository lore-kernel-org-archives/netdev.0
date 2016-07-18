From: Peter Chen <peter.feifan.chen@gmail.com>
Subject: Getting IP address and port of a file descriptor
Date: Mon, 18 Jul 2016 12:09:36 -0700
Message-ID: <CAMGYKAfWNm2d5n_3Tnxbwo2C1Ms+gNLp4C35BHmy-+Xwat0b+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33295 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832AbcGRTKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 15:10:10 -0400
Received: by mail-io0-f170.google.com with SMTP id 38so168574847iol.0
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 12:09:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

   I was wondering, if I was in the kernel, and I intercepted a system
call such as read(). Would I be able, from the fd, determine the
whether the fd is (1) a network socket? (2) the IP address and port of
this socket? What are the kernel data structures and functions that
can get these information for me in the kernel? Thanks.

Peter
