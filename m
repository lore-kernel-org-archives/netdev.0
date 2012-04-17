From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v3 5/5] r8169: support RTL8411
Date: Tue, 17 Apr 2012 13:05:19 +0200
Message-ID: <20120417110519.GA31624@electric-eye.fr.zoreil.com>
References: <1333089184-1773-5-git-send-email-hayeswang@realtek.com> <1333090086-1815-1-git-send-email-hayeswang@realtek.com> <20120330072521.GA11548@electric-eye.fr.zoreil.com> <52E71C7B42A44FB1A8556BB6B75CD9A0@realtek.com.tw> <20120405083743.GB32027@electric-eye.fr.zoreil.com> <20120409180229.GA28837@electric-eye.fr.zoreil.com> <E2A7860223AF4B52AFE7946163746F02@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37886 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752071Ab2DQLJt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 07:09:49 -0400
Content-Disposition: inline
In-Reply-To: <E2A7860223AF4B52AFE7946163746F02@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hayeswang <hayeswang@realtek.com> :
[...]
> The 8111C and the later chips have to set Config2 (0x53) bit 5 to enable PME
> status for WOL.

Thanks, 8402 and 8411 work way better now.

> Besides, the config1 (0x52) bit 0 is the read-only. Maybe you could skip
> setting it.

I have done it as well.

-- 
Ueimor
