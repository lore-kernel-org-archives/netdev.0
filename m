From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] de2104x: fix ethtool
Date: Mon, 27 Sep 2010 18:05:58 -0400
Message-ID: <4CA11546.8@pobox.com>
References: <201009272341.50668.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201009272341.50668.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/27/2010 05:41 PM, Ondrej Zary wrote:
> When the interface is up, using ethtool breaks it because:
> a) link is put down but media_timer interval is not shortened to NO_LINK
> b) rxtx is stopped but not restarted
>
> Also manual 10baseT-HD (and probably FD too - untested) mode does not work -
> the link is forced up, packets are transmitted but nothing is received.
> Changing CSR14 value to match documentation (not disabling link check) fixes this.
>
> Signed-off-by: Ondrej Zary<linux@rainbow-software.org>

Acked-by: Jeff Garzik <jgarzik@redhat.com>

Good catch on the missing de_start_rxtx()
