From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/5] sh_eth: WARN on access to a register not
 implemented in a particular chip
Date: Fri, 27 Feb 2015 18:21:24 +0300
Message-ID: <54F08B74.4000409@cogentembedded.com>
References: <1424982665.4444.70.camel@xylophone.i.decadent.org.uk> <1424982854.4444.73.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
To: Ben Hutchings <ben.hutchings@codethink.co.uk>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:44573 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbbB0PV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 10:21:28 -0500
Received: by lams18 with SMTP id s18so18203483lam.11
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 07:21:26 -0800 (PST)
In-Reply-To: <1424982854.4444.73.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/26/2015 11:34 PM, Ben Hutchings wrote:

> Currently we may silently read/write a register at offset 0.  Change
> this to WARN and then ignore the write or read-back all-ones.

    I think reading non-existing registers would yield all 0s, not all 1s.
That's not x86. :-)

> Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>

    Other than that, seems a great idea.

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

WBR, Sergei
