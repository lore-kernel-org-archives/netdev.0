From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] Ethtool: add EEE to ethtool's documentation
Date: Wed, 6 Jun 2012 16:56:28 +0100
Message-ID: <1338998188.2836.22.camel@bwh-desktop.uk.solarflarecom.com>
References: <1338878470-24784-1-git-send-email-yuvalmin@broadcom.com>
	 <1338878470-24784-3-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <eilong@broadcom.com>,
	<peppe.cavallaro@st.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:57524 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756972Ab2FFP4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 11:56:31 -0400
In-Reply-To: <1338878470-24784-3-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-05 at 09:41 +0300, Yuval Mintz wrote:
> under Synopsis:
> 	ethtool --get-eee devname
> 	ethtool --set-eee devname [eee on|off] [tx-lpi on|off] [tx-timer N] [advertise N]
> 
> under Options:
>        --get-eee
>               Queries  the  specified network device for its support in Efficient Energy Ethernet (ac-
> 	      cording to the IEEE 802.3az specifications)
>        --set-eee
> 	      Sets the device EEE behaviour.
>        eee on|off
> 	      Enables/Disables the device support in EEE.
>        tx-lpi on|off
> 	      Determines whether the device should assert its tx lpi.
>        advertise N
>               Sets the speeds for which the device would advertise EEE capabliities.   Values  are  as
> 	      for --change advertise
>        tx-timer N
>               Sets  the  amount  of time the device should stay in idle mode prior to asserting its tx
>               lpi (in microseconds). This has meaning only when tx lpi is on.

Please just fold this change into the patch that adds the options.  Also
there is no need to repeat the content in the commit message.

> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>  ethtool.8.in |   32 ++++++++++++++++++++++++++++++++
>  1 files changed, 32 insertions(+), 0 deletions(-)
> 
> diff --git a/ethtool.8.in b/ethtool.8.in
> index 523b737..b906d8e 100644
> --- a/ethtool.8.in
> +++ b/ethtool.8.in
> @@ -335,6 +335,16 @@ ethtool \- query or control network driver and hardware settings
>  .I devname flag
>  .A1 on off
>  .RB ...
> +.HP
> +.B ethtool \-\-get\-eee
> +.I devname
> +.HP
> +.B ethtool \-\-set\-eee
> +.I devname
> +.B2 eee on off
> +.B2 tx-lpi on off
> +.BN tx-timer
> +.BN advertise
>  .
>  .\" Adjust lines (i.e. full justification) and hyphenate.
>  .ad
> @@ -817,6 +827,28 @@ Sets the device's private flags as specified.
>  .I flag
>  .A1 on off
>  Sets the state of the named private flag.
> +.TP
> +.B \-\-get\-eee
> +Queries the specified network device for its support in Efficient Energy
> +Ethernet (according to the IEEE 802.3az specifications)

'of', not 'in'

> +.TP
> +.B \-\-set\-eee
> +Sets the device EEE behaviour.
> +.TP
> +.A2 eee on off
> +Enables/Disables the device support in EEE.

Lower-case 'd' for 'disables'.
'of', not 'in'

> +.TP
> +.A2 tx-lpi on off
> +Determines whether the device should assert its tx lpi.

'TX LPI' should be in upper-case.

> +.TP
> +.BI advertise \ N
> +Sets the speeds for which the device would advertise EEE capabliities.

'would', not 'should'
'capabilities', not 'capabliities'

> +Values are as for
> +.B \-\-change advertise
> +.TP
> +.BI tx-timer \ N
> +Sets the amount of time the device should stay in idle mode prior to asserting
> +its tx lpi (in microseconds). This has meaning only when tx lpi is on.

Same here.

Ben.

>  .SH BUGS
>  Not supported (in part or whole) on all network drivers.
>  .SH AUTHOR

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
