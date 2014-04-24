From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] rtlwifi: rtl8723be: disable MSI interrupts mode
Date: Thu, 24 Apr 2014 16:10:23 +0400
Message-ID: <5358FF2F.5030505@cogentembedded.com>
References: <1398308924-15312-1-git-send-email-adam.lee@canonical.com> <1398308924-15312-2-git-send-email-adam.lee@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: Adam Lee <adam.lee@canonical.com>, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:48947 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753483AbaDXMKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 08:10:25 -0400
Received: by mail-lb0-f175.google.com with SMTP id w7so1884794lbi.6
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 05:10:24 -0700 (PDT)
In-Reply-To: <1398308924-15312-2-git-send-email-adam.lee@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24-04-2014 7:08, Adam Lee wrote:

> 94010fa0dd07e8b904e7c6b6589f15573008ab15 introduced MSI interrupts mode

    Please also specify that commit's summary line in parens.

> support, which seemed safe enough with RTL8188EE and RTL8723BE as
> RealTek's testing results, but some users reported their RTL8188EE
> modules could not connect to any wireless network after the MSI mode was
> enabled by Ubuntu 14.04.

> So, let's fallback to pin-based mode until rtlwifi's MSI support get
> good compatibility.

> BugLink: https://bugs.launchpad.net/bugs/1310512
> Signed-off-by: Adam Lee <adam.lee@canonical.com>

WBR, Sergei
