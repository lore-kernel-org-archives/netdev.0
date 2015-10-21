From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH 08/15] net: wireless: simplify return flow for
 usb_control_msg
Date: Wed, 21 Oct 2015 17:00:31 +0200
Message-ID: <5627A88F.3030608@suse.cz>
References: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
 <1445439337-19055-9-git-send-email-punitvara@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: stas.yakovlev@gmail.com, chaoming_li@realsil.com.cn,
	Larry.Finger@lwfinger.net, chunkeey@googlemail.com,
	sgruszka@redhat.com, brudley@broadcom.com, arend@broadcom.com,
	linville@tuxdriver.com, mickflemm@gmail.com,
	mcgrof@do-not-panic.com, k.eugene.e@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, wcn36xx@lists.infradead.org,
	johannes.berg@intel.com, meuleman@broadcom.com
To: Punit Vara <punitvara@gmail.com>, kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445439337-19055-9-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2015, 04:55 PM, Punit Vara wrote:
> @@ -544,13 +544,10 @@ static void at76_ledtrig_tx_activity(void)
>  static int at76_remap(struct usb_device *udev)
>  {
>  	int ret;
> -	ret = usb_control_msg(udev, usb_sndctrlpipe(udev, 0), 0x0a,
> +	return usb_control_msg(udev, usb_sndctrlpipe(udev, 0), 0x0a,
>  			      USB_TYPE_VENDOR | USB_DIR_OUT |
>  			      USB_RECIP_INTERFACE, 0, 0, NULL, 0,
>  			      USB_CTRL_GET_TIMEOUT);
> -	if (ret < 0)
> -		return ret;
> -	return 0;

ret is now unused, right?

-- 
js
suse labs
