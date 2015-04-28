From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [for,4.1] rtlwifi: rtl8192cu: Fix kernel deadlock
Date: Tue, 28 Apr 2015 10:55:59 +0000 (UTC)
Message-ID: <20150428105559.12144141A32@smtp.codeaurora.org>
References: <1429891417-1224-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>,
	Bernhard Wiedemann <bwiedemann@suse.com>,
	Takashi Iwai <tiwai@suse.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33988 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933012AbbD1K4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 06:56:00 -0400
In-Reply-To: <1429891417-1224-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> The USB mini-driver in rtlwifi, which is used by rtl8192cu, issues a call to
> usb_control_msg() with a timeout value of 0. In some instances where the
> interface is shutting down, this infinite wait results in a CPU deadlock. A
> one second timeout fixes this problem without affecting any normal operations.
> 
> This bug is reported at https://bugzilla.novell.com/show_bug.cgi?id=927786.
> 
> Reported-by: Bernhard Wiedemann <bwiedemann@suse.com>
> Tested-by: Bernhard Wiedemann <bwiedemann@suse.com>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Stable <stable@vger.kernel.org>
> Cc: Bernhard Wiedemann <bwiedemann@suse.com>
> Cc: Takashi Iwai<tiwai@suse.com>

Thanks, applied to wireless-drivers.git.

Kalle Valo
