From: "Andy Gospodarek" <andy@greyhouse.net>
Subject: Re: [TG3]: Workaround MSI bug on 5714/5780.
Date: Wed, 5 Sep 2007 15:38:19 -0400
Message-ID: <bdfc5d6e0709051238q1184bf73r50ebb0e354c4bdaf@mail.gmail.com>
References: <1189022828.4960.2.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:4097 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932133AbXIETiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 15:38:20 -0400
Received: by an-out-0708.google.com with SMTP id d31so419813and
        for <netdev@vger.kernel.org>; Wed, 05 Sep 2007 12:38:19 -0700 (PDT)
In-Reply-To: <1189022828.4960.2.camel@dell>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/5/07, Michael Chan <mchan@broadcom.com> wrote:
> [TG3]: Workaround MSI bug on 5714/5780.
>
> A hardware bug was revealed after a recent PCI MSI patch was made to
> always disable legacy INTX when enabling MSI.  The 5714/5780 chips
> will not generate MSI when INTX is disabled, causing MSI failure
> messages to be reported, and another patch was made to workaround the
> problem by disabling MSI on ServerWorks HT1000 bridge chips commonly
> found with the 5714.
>
> We workaround this chip bug by enabling INTX after we enable MSI and
> after we resume from suspend.
>
> Update version to 3.81.
>
> This problem was discovered by David Miller.
>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
>

Seems reasonable.

Acked-by: Andy Gospodarek <andy@greyhouse.net>
