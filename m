From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [net-next PATCH v3 1/3] e1000: track BQL
 bytes regardless of skb or not
Date: Thu, 15 Sep 2016 23:29:34 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81F90900@ORSMSX101.amr.corp.intel.com>
References: <20160912220312.5610.77528.stgit@john-Precision-Tower-5810>
 <20160912221327.5610.74333.stgit@john-Precision-Tower-5810>
 <309B89C4C689E141A5FF6A0C5FB2118B81F90268@ORSMSX101.amr.corp.intel.com>
 <20160915004353.GA63116@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: John Fastabend <john.fastabend@gmail.com>,
        "bblanco@plumgrid.com" <bblanco@plumgrid.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "brouer@redhat.com" <brouer@redhat.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "u9012063@gmail.com" <u9012063@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45534 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752244AbcIOX3h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Sep 2016 19:29:37 -0400
In-Reply-To: <20160915004353.GA63116@ast-mbp.thefacebook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > ------------[ cut here ]------------
> > WARNING: CPU: 1 PID: 0 at net/sched/sch_generic.c:316
> dev_watchdog+0x1c2/0x1d0
> > NETDEV WATCHDOG: eth1 (e1000): transmit queue 0 timed out
> 
> Thanks a lot for the tests! Really appreciate it.

np, I needed to get my old compatibility systems back in running order anyway.
