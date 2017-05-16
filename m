From: Simon Horman <simon.horman@netronome.com>
Subject: Re: Advice on user space application integration with tc
Date: Tue, 16 May 2017 10:25:04 +0200
Message-ID: <20170516082500.GB15081@vergenet.net>
References: <CAHV_CwaAF-tDqEpPT1LL04tqTLE14qqqhxZtsB+d-ndKot8_UQ@mail.gmail.com>
 <CAM_iQpWnxTuHQfXzxQ6Cg5Ec=D7yJQsvw+3WpnzDuDXAUow7fg@mail.gmail.com>
 <CAHV_CwbvSbLXy7gfJdTWrrimk+MZP6r+fDZjqc1L8rkUA8p2Xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Morgan Yang <morgan.yang1982@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:35090 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751234AbdEPIZO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 04:25:14 -0400
Received: by mail-qk0-f170.google.com with SMTP id a72so120520726qkj.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 01:25:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAHV_CwbvSbLXy7gfJdTWrrimk+MZP6r+fDZjqc1L8rkUA8p2Xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 15, 2017 at 01:39:27PM -0700, Morgan Yang wrote:
> I tried on both stock CentOS 7.3 and Ubuntu 16.04 and tc-skbmod was
> not support (I built tc from the latest versions of iproute2). For
> tc-pedit, examples from man tc-pedit such as "pedit ex munge" were not
> supported, but "pedit munge offset" is.

Please don't top-post on netdev.

Unless I understand things "pedit ex munge" uses new features of ped which
were introduced in v4.11. So yes, you would need a new kernel - or a
backport to an old one - in order to use that feature.
