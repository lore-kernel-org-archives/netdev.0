From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3] r8169: fix invalid register dump
Date: Sun, 18 Aug 2013 23:21:52 +0200
Message-ID: <20130818212152.GA9974@electric-eye.fr.zoreil.com>
References: <1376833298-7321-1-git-send-email-lekensteyn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	nic_swsd <nic_swsd@realtek.com>
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60222 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755394Ab3HRVWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 17:22:07 -0400
Content-Disposition: inline
In-Reply-To: <1376833298-7321-1-git-send-email-lekensteyn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu <lekensteyn@gmail.com> :
[...]
> check"[1]. I do not have sis190 hardware, but since that is based on
> this r8169 driver, would it make sense to apply this patch to sis190
> too?

Yes for the _REGS_SIZE part. Nobody proved that the memcpy_fromio split
is needed or even useful with a sis19x.

-- 
Ueimor
