From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH V2] bluetooth: btusb: Fix issue with suspend
Date: Mon, 08 Sep 2014 20:39:03 -0500
Message-ID: <540E5A37.8020208@lwfinger.net>
References: <1410030368-23289-1-git-send-email-Larry.Finger@lwfinger.net> <EE5EAEAA-DA2E-4B0D-B961-8819F958E052@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	netdev@vger.kernel.org,
	Champion Chen <champion_chen@realsil.com.cn>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:33064 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755798AbaIIBjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 21:39:05 -0400
In-Reply-To: <EE5EAEAA-DA2E-4B0D-B961-8819F958E052@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2014 08:25 PM, Marcel Holtmann wrote:
> Hi Larry,
>
>> Suspend could fail for some platforms because
>> btusb_suspend==> btusb_stop_traffic ==> usb_kill_anchored_urbs,
>>
>> When btusb_bulk_complete returns before system suspend and resubmits an urb,
>> the system cannot enter suspend state.
>>
>> Signed-off-by: Champion Chen <champion_chen@realsil.com.cn>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> ---
>> V2 - Fix incorrect test as noted by Marcel.
>>
>> ---
>> Johan,
>>
>> To help Champion with the process, I have formatted the patch in
>> the correct manner. I hope I understand the issue correctly and
>> stated it in a coherent manner in the commit message.
>>
>> Larry
>> ---
>> drivers/bluetooth/btusb.c | 9 +++++++++
>> 1 file changed, 9 insertions(+)
>
> patch has been applied to bluetooth-next tree.

Thanks,

Larry
