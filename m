From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] staging: r8723au: Fix build warnings
Date: Wed, 09 Apr 2014 09:15:45 -0700
Message-ID: <1397060145.14321.21.camel@joe-AO722>
References: <1397055920-11654-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	devel@driverdev.osuosl.org, Jes Sorensen <Jes.Sorensen@redhat.com>,
	kbuild-all@01.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0088.hostedemail.com ([216.40.44.88]:46021 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933344AbaDIQPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 12:15:53 -0400
In-Reply-To: <1397055920-11654-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-04-09 at 10:05 -0500, Larry Finger wrote:
> The kbuild test robot reports the following:
[]
> diff --git a/drivers/staging/rtl8723au/include/rtw_mlme.h b/drivers/staging/rtl8723au/include/rtw_mlme.h
[]
> -void rtw_set_roaming(struct rtw_adapter *adapter, u8 to_roaming);
> -u8 rtw_to_roaming(struct rtw_adapter *adapter);
> +inline void rtw_set_roaming(struct rtw_adapter *adapter, u8 to_roaming);
> +inline u8 rtw_to_roaming(struct rtw_adapter *adapter);

I think this doesn't make sense.

Either the inline should be removed from
the .c file or the function should be moved
into the .h file and made static inline.
