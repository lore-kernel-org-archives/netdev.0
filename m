From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] hso: memory leak in hso_serial_common_free()
Date: Thu, 19 Nov 2009 12:20:28 -0800 (PST)
Message-ID: <20091119.122028.155178577.davem@davemloft.net>
References: <1C487791B6A047B7A26F2B3C54BE0A70@mschille2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mschiller@tdt.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755536AbZKSUUM@vger.kernel.org>
In-Reply-To: <1C487791B6A047B7A26F2B3C54BE0A70@mschille2>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Martin Schiller" <mschiller@tdt.de>
Date: Thu, 19 Nov 2009 09:43:57 +0100

> This patch fixes a memory leak in the hso_serial_common_free()
> function.
> The tx_buffer of a serial device was never freed here.
> 
> Signed-off-by: Martin Schiller <mschiller@tdt.de>

All three of your patches have been severely corrupted by
your email client.  Sequences of one or more tab characters
have been converted in a single space, etc.

> 09:04:29.000000000 +0100
> @@ -2296,6 +2296,7 @@ static void hso_serial_common_free(struc
>  /* unlink and free TX URB */
>  usb_free_urb(serial->tx_urb);
>  kfree(serial->tx_data);
> + kfree(serial->tx_buffer);
> }
> 

This makes your changes unusable.

You've already gone through two iterations trying to submit
these bug fixes.  Please take some time out to verify that
your outging patches in emails can be received accurately
and applied by the receiver (send the patch to yourself
and try to apply it, for example).

Thanks.
