From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [net-next 2/8] e1000e: initial support for i217
Date: Sat, 05 May 2012 10:01:39 +0200
Message-ID: <87mx5njbto.fsf@nemi.mork.no>
References: <1336127716-20383-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1336127716-20383-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Bruce Allan <bruce.w.allan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:47052 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752130Ab2EEIBz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2012 04:01:55 -0400
In-Reply-To: <1336127716-20383-3-git-send-email-jeffrey.t.kirsher@intel.com>
	(Jeff Kirsher's message of "Fri, 4 May 2012 03:35:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher <jeffrey.t.kirsher@intel.com> writes:

> diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/ne=
t/ethernet/intel/e1000e/defines.h
> index 3a50259..11c4666 100644
> --- a/drivers/net/ethernet/intel/e1000e/defines.h
> +++ b/drivers/net/ethernet/intel/e1000e/defines.h
> @@ -74,7 +74,9 @@
>  #define E1000_WUS_BC           E1000_WUFC_BC
> =20
>  /* Extended Device Control */
> +#define E1000_CTRL_EXT_LPCD  0x00000004     /* LCD Power Cycle Done =
*/
>  #define E1000_CTRL_EXT_SDP3_DATA 0x00000080 /* Value of SW Definable=
 Pin 3 */
> +#define E1000_CTRL_EXT_FORCE_SMBUS 0x00000004 /* Force SMBus mode*/
>  #define E1000_CTRL_EXT_EE_RST    0x00002000 /* Reinitialize from EEP=
ROM */
>  #define E1000_CTRL_EXT_SPD_BYPS  0x00008000 /* Speed Select Bypass *=
/
>  #define E1000_CTRL_EXT_RO_DIS    0x00020000 /* Relaxed Ordering disa=
ble */

The mangled sorting and alignment of the new entries made me wonder if
this was a typo.  But reading further below it looks like
E1000_CTRL_EXT_LPCD is input and E1000_CTRL_EXT_FORCE_SMBUS is output.
If that is correct, then it probably deserves a small comment here alon=
g
with better sorting and alignment to make it clear that the duplicate
value is intentional?


Bj=C3=B8rn
