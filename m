From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/1] Net: kconfig, correct traffic shaper
Date: Mon, 06 Nov 2006 02:52:02 -0500
Message-ID: <454EE9A2.4060908@pobox.com>
References: <453BA26D.9010504@trash.net>, <43123154321532@wsc.cz> <1202725131414221392@wsc.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	Alan Cox <alan@redhat.com>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:62593 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932793AbWKFHwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 02:52:10 -0500
To: Jiri Slaby <jirislaby@gmail.com>
In-Reply-To: <1202725131414221392@wsc.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Slaby wrote:
> Patrick McHardy <kaber@trash.net> wrote:
>> While you're at it .. CBQ is actually not a very good alternative
>> since it doesn't work properly on top of virtual network devices.
>> The closest match for an alternative would be TBF, but HTB and
>> HFSC also do fine. Maybe just point to the traffic schedulers in
>> general. I think you could also change EXPERIMENTAL to OBSOLETE
>> for the shaper device, the traffic schedulers are a lot more
>> flexible.
> 
> Ok, thanks for comments. Here it comes, please (n)ack it:
> 
> --
> 
> kconfig, correct traffic shaper
> 
> As Patrick McHardy <kaber@trash.net> suggested, Traffic Shaper is
> now obsolete and alternative to it is no longer CBQ, since its problems with
> virtual devices, alter Kconfig text to reflect this -- put a link to the
> traffic schedulers as a whole.
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
> Cc: Alan Cox <alan@redhat.com>
> Cc: Patrick McHardy <kaber@trash.net>

ACK from me, though I think that since it relates to traffic schedulers 
I think this patch should be merged through DaveM...

	Jeff


