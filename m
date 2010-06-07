From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch 2/2] mlx4: add dynamic LRO disable support
Date: Mon, 07 Jun 2010 21:15:46 +0800
Message-ID: <4C0CF102.8090603@redhat.com>
References: <20100603034303.5305.55552.sendpatchset@localhost.localdomain>	<20100603034312.5305.61000.sendpatchset@localhost.localdomain>	<1275568622.2870.89.camel@localhost>	<4C085D45.6040001@redhat.com>	<1275661552.2095.13.camel@achroite.uk.solarflarecom.com>	<4C0CB325.2040704@redhat.com> <20100607130038.11581e28@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	herbert.xu@redhat.com, nhorman@redhat.com, davem@davemloft.net
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49804 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032Ab0FGNLr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jun 2010 09:11:47 -0400
In-Reply-To: <20100607130038.11581e28@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/10 19:00, Stanislaw Gruszka wrote:
> On Mon, 07 Jun 2010 16:51:49 +0800
> Cong Wang<amwang@redhat.com>  wrote:
>
>>> Now that I look at the patch again, I see you're using a static (i.e.
>>> global) variable to 'back up' the non-zero (enabled) value of num_lro.
>>> This is introducing a bug!  The correct value is apparently set in
>>> mlx4_en_get_profile(); you would need to replicate that.
>>>
>>
>> Oh, probably, but unfortunately 'num_lro' is static so only visible
>> in en_main.c.
>
> So just remove "static" and make it global :-)
>

Not that easy, it is defined with a macro which is also used
by other parameters. :-/

