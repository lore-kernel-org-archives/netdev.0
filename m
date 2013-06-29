From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: reset rx mode when do suspend/resume or link
 status change
Date: Fri, 28 Jun 2013 21:25:02 -0700 (PDT)
Message-ID: <20130628.212502.382862892673771496.davem@davemloft.net>
References: <1372309759-5067-1-git-send-email-B38611@freescale.com>
	<20130627131503.GC2695@S2101-09.ap.freescale.net>
	<CAOMZO5DJ0hfXEdXK8etztoW0QorvCkX1j48EQ478+6O0tKWURA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, B38611@freescale.com, b20596@freescale.com,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	R49496@freescale.com, stephen@networkplumber.org,
	christoph.muellner@theobroma-systems.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46178 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab3F2EZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 00:25:03 -0400
In-Reply-To: <CAOMZO5DJ0hfXEdXK8etztoW0QorvCkX1j48EQ478+6O0tKWURA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Thu, 27 Jun 2013 10:21:14 -0300

> On Thu, Jun 27, 2013 at 10:15 AM, Shawn Guo <shawn.guo@linaro.org> wrote:
>> On Thu, Jun 27, 2013 at 01:09:19PM +0800, Fugang Duan wrote:
>>> When do suspend/resume, or plug/unplug network cable, or net watchdog
>>> timeout process, fec_restart reinit the enet group hash table to zero.
>>>
>>> It is not reasonable for this, so re-config the enet group hash table
>>> when these actions happen.
>>>
>>> Signed-off-by: Fugang Duan  <B38611@freescale.com>
>>> ---
>>>  drivers/net/ethernet/freescale/fec_main.c |  153 ++++++++++++++---------------
>>>  1 files changed, 76 insertions(+), 77 deletions(-)
>>
>> A forward declaration of set_multicast_list() can simply save these
>> dramatic diff stat?
> 
> Correct, and this has been already been posted:
> http://patchwork.ozlabs.org/patch/253290/

A new version of that patch needs to be posted, and then this one respun
against it.
