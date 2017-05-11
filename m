From: Morgan Yang <morgan.yang1982@gmail.com>
Subject: Advice on user space application integration with tc
Date: Thu, 11 May 2017 13:45:48 -0700
Message-ID: <CAHV_CwaAF-tDqEpPT1LL04tqTLE14qqqhxZtsB+d-ndKot8_UQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f172.google.com ([209.85.216.172]:33856 "EHLO
        mail-qt0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754916AbdEKUpt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 16:45:49 -0400
Received: by mail-qt0-f172.google.com with SMTP id j29so27438126qtj.1
        for <netdev@vger.kernel.org>; Thu, 11 May 2017 13:45:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All:

I want to build a solution that leverages the filtering and actions of
tc in kernel space, but have the ability to hook  to a userspace
application that can additional packet processing (such as payload
masking). I'm curious what are the best ways to go about doing that? I
have been looking into tc-skbmod and tc-pedit, but as good as they
are, they would require newer kernels. I have also tried using tc to
mirror filterd packets to a dummy or tap interface, and have the
userspace application pick up there, but the performance has been
supar. I'm hoping to have a solution that avoids the extra mirroring.
Much Thanks
Morgan Yang
