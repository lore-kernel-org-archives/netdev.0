From: Kalle Valo <kvalo@codeaurora.org>
Subject: btcoex subsystem
Date: Tue, 03 Feb 2015 14:29:38 +0200
Message-ID: <874mr3xjnx.fsf_-_@kamboji.qca.qualcomm.com>
References: <1422304934-9239-1-git-send-email-Larry.Finger@lwfinger.net>
	<1422304934-9239-6-git-send-email-Larry.Finger@lwfinger.net>
	<87h9v8zkuh.fsf@kamboji.qca.qualcomm.com>
	<EC423C22-AEA0-4232-A452-7A131C41780A@holtmann.org>
	<54CBA0CE.8030800@lwfinger.net>
	<B814EF26-CBC9-43E4-A6C9-761A013F85C1@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Troy Tan <troy_tan@realsil.com.cn>, netdev@vger.kernel.org,
	linux-bluetooth@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:59415 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755745AbbBCM3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 07:29:46 -0500
In-Reply-To: <B814EF26-CBC9-43E4-A6C9-761A013F85C1@holtmann.org> (Marcel
	Holtmann's message of "Fri, 30 Jan 2015 10:05:24 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel Holtmann <marcel@holtmann.org> writes:

>> I will work on combining the latest BT drivers from Realtek with
>> btusb to see if I can achieve a patch that will both work with the
>> Realtek hardware, and get approval from the reviewers.
>> 
>> What would be an approved method of communicating between two kernel
>> modules? Is there some example in the kernel that I could study?
>
> We need a btcoex subsystem that both WiFi and Bluetooth can register
> to and communicate with.

The need for this seems to periodically come up, I remember needing
something like that back in the Maemo wl1251 days and also ath6kl needed
this. Are there any ideas for this subsystem? How would this btcoex
subsystem work? What kind of information would it provide?

Is this something we should discuss at Ottawa?

-- 
Kalle Valo
