From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Advice on user space application integration with tc
Date: Tue, 16 May 2017 10:22:29 -0700
Message-ID: <CAM_iQpVKfdSb0nmmXojZMo+pj5qxf9nSy14ScpYu_UG=jJaN_A@mail.gmail.com>
References: <CAHV_CwaAF-tDqEpPT1LL04tqTLE14qqqhxZtsB+d-ndKot8_UQ@mail.gmail.com>
 <CAM_iQpWnxTuHQfXzxQ6Cg5Ec=D7yJQsvw+3WpnzDuDXAUow7fg@mail.gmail.com> <CAHV_CwaesEdmR+=Kr-O+NUCwGC4KNJZvXcDV3qNmji38OtZOeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Morgan Yang <morgan.yang1982@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36512 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751052AbdEPRWv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:22:51 -0400
Received: by mail-wm0-f53.google.com with SMTP id u65so129160446wmu.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 10:22:51 -0700 (PDT)
In-Reply-To: <CAHV_CwaesEdmR+=Kr-O+NUCwGC4KNJZvXcDV3qNmji38OtZOeg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 15, 2017 at 1:33 PM, Morgan Yang <morgan.yang1982@gmail.com> wrote:
> I tried on both stock CentOS 7.3 and Ubuntu 16.04 and tc-skbmod was not
> support (I built tc from the latest versions of iproute2). For tc-pedit,
> examples from man tc-pedit such as "pedit ex munge" were not supported, but
> "pedit munge offset" is.

act skbmod is new, it is introduced by:

commit 86da71b57383d40993cb90baafb3735cffe5d800
Author: Jamal Hadi Salim <jhs@mojatatu.com>
Date:   Mon Sep 12 20:13:09 2016 -0400

    net_sched: Introduce skbmod action

For pedit, "ex", as it implies, it is an extended feature which was
introduced in:

commit 71d0ed7079dffbc5cd0941d77d9b84e04109c9bb
Author: Amir Vadai <amir@vadai.me>
Date:   Tue Feb 7 09:56:07 2017 +0200

    net/act_pedit: Support using offset relative to the conventional
network headers
