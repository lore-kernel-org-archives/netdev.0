From: Feng Kan <fkan@apm.com>
Subject: Re: [PATCH V2] net: eth: xgene: change APM X-Gene SoC platform
 ethernet to support ACPI
Date: Tue, 6 Jan 2015 11:30:46 -0800
Message-ID: <CAL85gmDybxCB59UcpFm3NRR7bxG-_1xsmXAs3oehOujEoetiog@mail.gmail.com>
References: <20150105.224137.894770670718334587.davem@davemloft.net>
	<20150105.224235.1941007145649816230.davem@davemloft.net>
	<CAL85gmCGK54yK3sThVhGsatMVUS8+76LRwdDt4w9PUfppMJ3og@mail.gmail.com>
	<20150105.231054.790363276763745624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: patches <patches@apm.com>, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og112.obsmtp.com ([64.18.0.24]:38824 "HELO
	exprod5og112.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756686AbbAFTas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 14:30:48 -0500
Received: by mail-ob0-f180.google.com with SMTP id wp4so67281029obc.11
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 11:30:46 -0800 (PST)
In-Reply-To: <20150105.231054.790363276763745624.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 5, 2015 at 8:10 PM, David Miller <davem@davemloft.net> wrote:
> From: Feng Kan <fkan@apm.com>
> Date: Mon, 5 Jan 2015 20:05:28 -0800
>
>> I see, I initially tried on the net-next tree which did not build for
>> me, failed somewhere else but builds xgene enet ok.
>> Then I tested on net/master which builds fine for me.
>> Would you please point me to the branch you are using?
>
> net-next
David, I am not sure what I am missing here. I encountered a lot of
errors while compiling
the net-next.git. Mostly complaining of implicit declaration of
functions. Once I fixed those,
the compilation passes fine for defconfig in arm64. By default OF
should be enabled for
the platform, I am not sure how to recreate this. I have tested the
image for OF and ACPI
and both works.
