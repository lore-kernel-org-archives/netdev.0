From: Jiri Pirko <jiri@resnulli.us>
Subject: nfp bpf offload add/replace
Date: Thu, 7 Sep 2017 11:10:33 +0200
Message-ID: <20170907091033.GD1967@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mlxsw@mellanox.com
To: kubakici@wp.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:37995 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754349AbdIGJKg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 05:10:36 -0400
Received: by mail-qt0-f178.google.com with SMTP id q8so21644804qtb.5
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 02:10:35 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Kuba.

I'm looking into cls_bpf code and nfp_net_bpf_offload function in your
driver. Why do you need TC_CLSBPF_ADD? Seems like TC_CLSBPF_REPLACE
should be enough. It would make the cls_bpf code easier.

Note that other cls just have replace/destroy (u32 too, as drivers
handle NEW/REPLACE in one switch-case - will patch this).

Thanks!

Jiri
