From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] de2104x: fix ethtool
Date: Mon, 27 Sep 2010 15:40:41 -0700 (PDT)
Message-ID: <20100927.154041.137841283.davem@davemloft.net>
References: <201009272341.50668.linux@rainbow-software.org>
	<4CA11546.8@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@rainbow-software.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CA11546.8@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Mon, 27 Sep 2010 18:05:58 -0400

> On 09/27/2010 05:41 PM, Ondrej Zary wrote:
>> When the interface is up, using ethtool breaks it because:
>> a) link is put down but media_timer interval is not shortened to
>> NO_LINK
>> b) rxtx is stopped but not restarted
>>
>> Also manual 10baseT-HD (and probably FD too - untested) mode does not
>> work -
>> the link is forced up, packets are transmitted but nothing is
>> received.
>> Changing CSR14 value to match documentation (not disabling link check)
>> fixes this.
>>
>> Signed-off-by: Ondrej Zary<linux@rainbow-software.org>
> 
> Acked-by: Jeff Garzik <jgarzik@redhat.com>
> 
> Good catch on the missing de_start_rxtx()

Applied, thanks everyone.
