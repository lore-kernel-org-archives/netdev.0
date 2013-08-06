From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 1/2] ip_tunnel: embed hash list head
Date: Tue, 6 Aug 2013 10:41:11 -0700
Message-ID: <CALnjE+pN5=Ay0TBTVpccNTw9hTFvHn5=sjMx-Wv=Ms6_AA9hvg@mail.gmail.com>
References: <20130805225137.6c934d7f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:58620 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756384Ab3HFRlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 13:41:14 -0400
Received: by mail-qa0-f50.google.com with SMTP id f14so500644qak.2
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 10:41:12 -0700 (PDT)
In-Reply-To: <20130805225137.6c934d7f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 5, 2013 at 10:51 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> The IP tunnel hash heads can be embedded in the per-net structure
> since it is a fixed size. Reduce the size so that the total structure
> fits in a page size. The original size was overly large, even NETDEV_HASHBITS
> is only 8 bits!
>
> Also, add some white space for readability.
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>
>
Looks good.
Acked-by: Pravin B Shelar <pshelar@nicira.com>.
