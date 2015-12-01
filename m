From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH v3 4/4] net: diag: Support destroying TCP sockets.
Date: Tue, 1 Dec 2015 16:12:52 +0900
Message-ID: <CAKD1Yr3HzKrgu4YKNpaVsoLCoDv+gi1SNiqMER_L_Fwnmkq1wQ@mail.gmail.com>
References: <1448937147-38043-5-git-send-email-lorenzo@google.com> <201512011411.INarbTNn%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Erik Kline <ek@google.com>, Tom Herbert <tom@herbertland.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:33325 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbbLAHNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 02:13:13 -0500
Received: by ykdv3 with SMTP id v3so214239437ykd.0
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 23:13:12 -0800 (PST)
In-Reply-To: <201512011411.INarbTNn%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 1, 2015 at 3:23 PM, kbuild test robot <lkp@intel.com> wrote:
>>> ERROR: "tcp_send_active_reset" undefined!

I used tcp_send_active_reset from tcp_diag.ko without an
EXPORT_SYMBOL_GPL in net/ipv4/tcp_output.c. Fixed in patch v4.
