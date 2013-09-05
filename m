From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: rtl8188eu array/null comparison.
Date: Wed, 04 Sep 2013 22:14:24 -0500
Message-ID: <5227F710.1080602@lwfinger.net>
References: <20130904233018.GB5727@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:49690 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305Ab3IEDO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 23:14:26 -0400
Received: by mail-ob0-f180.google.com with SMTP id v19so1349174obq.39
        for <netdev@vger.kernel.org>; Wed, 04 Sep 2013 20:14:25 -0700 (PDT)
In-Reply-To: <20130904233018.GB5727@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04/2013 06:30 PM, Dave Jones wrote:
> Hi Larry,
>
> in drivers/staging/rtl8188eu/core/rtw_mlme.c:rtw_check_join_candidate there's this code..
>
> 1721         /* check ssid, if needed */
> 1722         if (pmlmepriv->assoc_ssid.Ssid && pmlmepriv->assoc_ssid.SsidLength) {
> 1723                 if (competitor->network.Ssid.SsidLength != pmlmepriv->assoc_ssid.SsidLength ||
> 1724                     _rtw_memcmp(competitor->network.Ssid.Ssid, pmlmepriv->assoc_ssid.Ssid, pmlmepriv->assoc_ssid.SsidLength) == false)
> 1725                         goto exit;
> 1726         }
> 1727
>
> assoc_ssid.Ssid being an array, this comparison against null probably isn't what was intended ?

I think that a non-zero SsidLength should be enough of a test, but I need to 
think about a bit more.

Thanks,

Larry
