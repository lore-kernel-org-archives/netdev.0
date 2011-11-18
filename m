From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next] r8169: Add 64bit statistics
Date: Fri, 18 Nov 2011 10:18:43 +0100
Message-ID: <20111118091843.GA30303@electric-eye.fr.zoreil.com>
References: <20111117064826.GA4429@Desktop-Junchang> <20111117093635.GA9112@electric-eye.fr.zoreil.com> <CABoNC816GL4vqbHSR8BYrOFFuL_ZSqxS1xqmG02uwpKkwKNJDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38234 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754292Ab1KRJYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 04:24:10 -0500
Content-Disposition: inline
In-Reply-To: <CABoNC816GL4vqbHSR8BYrOFFuL_ZSqxS1xqmG02uwpKkwKNJDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Junchang Wang <junchangwang@gmail.com> :
[...]
> I'm not sure which hardware stats registers are accurate.

See rtl8169_gstrings.

> Besides, it seem r8169.c are also designed for other chipsets (8129?).

Afaik the basic statistics are consistent through the 816x and
810{2, 3} family.

> I would like other people who are quite familiar with those chipsets
> to do this job.
> 
> Is that OK ? Thanks.

Fair enough.

Eric's "ethtool -S = hardware, ip -s = software" remark makes sense
anyway. So there is no reason to be retentive.

-- 
Ueimor
