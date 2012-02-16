From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/5] usb: cdc-ncm: Change alternate setting magic numbers
 into #defines
Date: Thu, 16 Feb 2012 19:34:10 +0100
Message-ID: <CAL_Kpj2+oZiQV8PFuAVRpMYwUciG_7gJLQJ73vRYEUBC2SfpBA@mail.gmail.com>
References: <1329317261-3406-1-git-send-email-toby.gray@realvnc.com>
	<1329317261-3406-2-git-send-email-toby.gray@realvnc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Toby Gray <tg-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>, Oliver Neukum <oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Toby Gray <toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1329317261-3406-2-git-send-email-toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 15, 2012 at 3:47 PM, Toby Gray <toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org> wrot=
e:

> +/* CDC NCM ch. 5.3 describes alternate setting 0 as having no
> + * endpoints and therefore not allowing any networking traffic. */
> +#define =A0 =A0 =A0 =A0CDC_NCM_ALTSETTING_RESET =A0 =A0 =A0 =A00

Please, use bulk in the both define names to distinguish from control
ep alt settings in the next version of the specification, i.e.
something like CDC_NCM_BULK_ALTSETTING_NO_DATA
This is the setting with no endpoints (no data).

> +/* CDC NCM ch. 5.3 describes alternate setting 1 as having the
> + * required bulk endpoints for normal operation. */
> +#define =A0 =A0 =A0 =A0CDC_NCM_ALTSETTING_DATA =A0 =A0 =A0 =A0 1

Regards,
Alexey
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
