From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: Re: [PATCH, resubmit] ax88179_178a: ASIX AX88179_178A USB 3.0/2.0
 to gigabit ethernet adapter driver
Date: Wed, 6 Feb 2013 21:46:03 -0800
Message-ID: <20130206214603.72524632@nehalam.linuxnetplumber.net>
References: <1360211794-4737-1-git-send-email-freddy@asix.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1360211794-4737-1-git-send-email-freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu,  7 Feb 2013 12:36:34 +0800
Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org> wrote:

> +static struct ethtool_ops ax88179_ethtool_ops = {
> +	.get_link		= ethtool_op_get_link,
> +	.get_msglevel		= usbnet_get_msglevel,
> +	.set_msglevel		= usbnet_set_msglevel,
> +	.get_wol		= ax88179_get_wol,
> +	.set_wol		= ax88179_set_wol,
> +	.get_eeprom_len		= ax88179_get_eeprom_len,
> +	.get_eeprom		= ax88179_get_eeprom,
> +	.get_settings		= ax88179_get_settings,
> +	.set_settings		= ax88179_set_settings,
> +	.nway_reset		= usbnet_nway_reset,
> +};
> +

ethtool_ops should always be const
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
