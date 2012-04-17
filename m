From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] set fake_rtable's dst to NULL to avoid kernel Oops.
Date: Tue, 17 Apr 2012 18:48:43 +0200
Message-ID: <1334681323.2472.43.camel@edumazet-glaptop>
References: <000001cd1c62$75d10de0$617329a0$%huangpeng@huawei.com>
	 <20120417085248.3e642294@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Peter Huang (Peng)" <peter.huangpeng@huawei.com>,
	"'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ctrix+debianbugs@navynet.it,
	peter.huangpeng@gmail.com, harry.majun@huawei.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35387 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570Ab2DQQsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 12:48:51 -0400
In-Reply-To: <20120417085248.3e642294@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-17 at 08:52 -0700, Stephen Hemminger wrote:

> This check seems like a disaster waiting to happen when the next
> change to DST table happens.

Please Peter Document this, adding a new DST_FAKE_RTABLE flag

#define DST_FAKE_RTABLE DST_NOPEER

or just use a bit, we have plenty of them available.
