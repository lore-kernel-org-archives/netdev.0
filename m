From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net] net/mlx4_core: Fix Oops on reboot when SRIOV VFs are
 probed into the Host
Date: Sun, 8 Jun 2014 12:18:02 +0300
Message-ID: <CAJZOPZLU0_9eryiBtHSetoK35qcyU-zTRxtpKoyBxKNg0N9HMw@mail.gmail.com>
References: <1401619783-23659-1-git-send-email-ogerlitz@mellanox.com>
	<20140602142947.GB28523@richard>
	<CAErSpo4GNxMMWyfcSnMKp65M6DAVwQkRCTuCbt+sWkOJTVt9Cw@mail.gmail.com>
	<CAJZOPZK94-hZfBtpjFMEd5m1STRxbs-wTYsKB5SoC=zES5XfPg@mail.gmail.com>
	<20140606025200.GA6981@richard>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Tal Alon <talal@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:42756 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469AbaFHJSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jun 2014 05:18:04 -0400
Received: by mail-qg0-f46.google.com with SMTP id q108so7365964qgd.5
        for <netdev@vger.kernel.org>; Sun, 08 Jun 2014 02:18:02 -0700 (PDT)
In-Reply-To: <20140606025200.GA6981@richard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 6, 2014 at 5:52 AM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
> After understanding the root cause of this error, I come up with another kind
> of fix to this case. Verification has been done on my machine, it looks good
> to me. If your team could verify this, it would be better :-)

looks good, let me do some re-wording and I will submit it, with you
being the author
