From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH 00/11 V2] rtlwifi: A set of patches that simplify the drivers
Date: Wed, 07 Jan 2015 19:57:07 +0200
Message-ID: <87y4pepj7w.fsf@kamboji.qca.qualcomm.com>
References: <1420559892-12384-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420559892-12384-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
	(Larry Finger's message of "Tue, 6 Jan 2015 09:58:01 -0600")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> writes:

> Happy New Year.
>
> This set of patches, which are intended for the 3.20 stream, are intended to
> simplify the drivers. In particular, each of them has a separate routine that
> initilizes the dynamic power manipulation variables. Ten of these patches convert
> the drivers to use a common copy of this code. The other patch updates the
> parameter descriptions of rtl8723be to clarify usage.
>
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> ---
>
> V2 - only patch 02/11 is changed to fix the problem noted by Sergei Shylyov
>      <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org> concerning a line that was dropped.
>
> Larry Finger (11):
>   rtlwifi: Unify variable naming for all drivers
>   rtlwifi: rtl8723be: Improve modinfo output
>   rtlwifi: Create new routine to initialize the DM tables
>   rtlwifi: rtl8188ee: Convert driver to use the common DM table init
>     routine
>   rtlwifi: rtl8192c-common: Convert driver to use common DM table
>     initialization
>   rtlwifi: rtl8192de: Convert driver to use common DM table
>     initialization
>   rtlwifi: rtl8192ee: Convert driver to use common DM table
>     initialization
>   rtlwifi: rtl8723ae: Convert driver to use common DM table
>     initialization
>   rtlwifi: rtl8723be: Convert driver to use common DM table
>     initialization
>   rtlwifi: rtl8821ae: Convert driver to use common DM table
>     initialization
>   rtlwifi: Move macro definitions to core

Thanks, all 11 applied to wireless-drivers-next.git.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
