From: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] IrDA: Support for Sigmatel STIR421x chip
Date: Wed, 05 Apr 2006 22:41:26 -0700 (PDT)
Message-ID: <20060405.224126.19316235.davem@davemloft.net>
References: <20060405232137.GB377@irie>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org
In-Reply-To: <20060405232137.GB377@irie>
Sender: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date: Thu, 6 Apr 2006 02:21:37 +0300

> This patch enables support for the Sigmatel's STIR421x IrDA chip.
> Once patched with Sigmatel's firmware, this chip "almost" follows the USB-IrDA spec. Thus this patch is against irda-usb.[ch].
> 
> The code has been tested by Nick Fedchik on an STIR4210 chipset based dongle.
> 
> Signed-off-by: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

Applied, but I had to fix up an enormous amount of trailing
white space on this patch too.

Also, functions such as stir421x_upload_patch() were not properly
indented using tabs, it's using a 4 space indentation.

Lots of other coding style errors such as:

	if(cond) {

instead of:

	if (cond) {

You may wish to review Documentation/CodingStyle before submitting
future IRDA patches.

Thanks a lot.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
