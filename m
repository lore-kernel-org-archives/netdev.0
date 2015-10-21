From: punit vara <punitvara@gmail.com>
Subject: Re: [PATCH 08/15] net: wireless: simplify return flow for usb_control_msg
Date: Wed, 21 Oct 2015 23:35:06 +0530
Message-ID: <CABXAfNJwZV7u9ZGF4p3--mz1gnLGnGVmcAJnq7o9H_jheD9r5w@mail.gmail.com>
References: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
	<1445439337-19055-9-git-send-email-punitvara@gmail.com>
	<5627A88F.3030608@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@qca.qualcomm.com>, stas.yakovlev@gmail.com,
	chaoming_li@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Christian Lamparter <chunkeey@googlemail.com>,
	sgruszka@redhat.com, brudley@broadcom.com, arend@broadcom.com,
	John Linville <linville@tuxdriver.com>,
	Nick Kossifidis <mickflemm@gmail.com>, mcgrof@do-not-panic.com,
	Eugene Krasnikov <k.eugene.e@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, wcn36xx@lists.infradead.org,
	johannes.berg@intel.com, meuleman@broadcom.com
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:34603 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbbJUSFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 14:05:07 -0400
In-Reply-To: <5627A88F.3030608@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2015 at 8:30 PM, Jiri Slaby <jslaby@suse.cz> wrote:
> On 10/21/2015, 04:55 PM, Punit Vara wrote:
>> @@ -544,13 +544,10 @@ static void at76_ledtrig_tx_activity(void)
>>  static int at76_remap(struct usb_device *udev)
>>  {
>>       int ret;
>> -     ret = usb_control_msg(udev, usb_sndctrlpipe(udev, 0), 0x0a,
>> +     return usb_control_msg(udev, usb_sndctrlpipe(udev, 0), 0x0a,
>>                             USB_TYPE_VENDOR | USB_DIR_OUT |
>>                             USB_RECIP_INTERFACE, 0, 0, NULL, 0,
>>                             USB_CTRL_GET_TIMEOUT);
>> -     if (ret < 0)
>> -             return ret;
>> -     return 0;
>
> ret is now unused, right?
>
> --
> js
> suse labs
Oppp..Sorry I have missed int ret to remove . I will resend the
updated patch soon
