From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [1/1] rsi: eliminate superfluous NULL check
Date: Tue, 14 Jun 2016 14:18:18 +0000 (UTC)
Message-ID: <20160614141818.2ED106120D@smtp.codeaurora.org>
References: <1463524241-11351-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Nicholas Mc Guire <hofrat@osadl.org>,
	Johannes Berg <johannes.berg@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Heinrich Schuchardt <xypron.glpk@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:59033 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbcFNOSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 10:18:18 -0400
In-Reply-To: <1463524241-11351-1-git-send-email-xypron.glpk@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Heinrich Schuchardt <xypron.glpk@gmx.de> wrote:
> msg is dereferenced before checking against NULL, e.g.
> when assigning pad_bytes.
> Remove the superfluous check in function rsi_mgmt_pkt_to_core.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Thanks, 1 patch applied to wireless-drivers-next.git:

9b648d788d78 rsi: eliminate superfluous NULL check

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9115441/
