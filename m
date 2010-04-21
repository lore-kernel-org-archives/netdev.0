From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] gianfar: Wait for both RX and TX to stop
Date: Wed, 21 Apr 2010 07:17:28 -0500
Message-ID: <10AE27BE-1830-4AAD-83E6-20001BC430D8@kernel.crashing.org>
References: <o2oed82fe3e1004200801n98683cdalb2898c879b93f8fd@mail.gmail.com> <20100420.180646.216759318.davem@davemloft.net> <A20F7457-20BC-493C-B800-3933D8FC4D5C@kernel.crashing.org> <20100420.223659.236667659.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: timur.tabi@gmail.com, afleming@freescale.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:35856 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753623Ab0DUMRi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 08:17:38 -0400
In-Reply-To: <20100420.223659.236667659.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 21, 2010, at 12:36 AM, David Miller wrote:

> From: Kumar Gala <galak@kernel.crashing.org>
> Date: Tue, 20 Apr 2010 23:22:19 -0500
> 
>> 
>> On Apr 20, 2010, at 8:06 PM, David Miller wrote:
>> 
>>> From: Timur Tabi <timur.tabi@gmail.com>
>>> Date: Tue, 20 Apr 2010 10:01:48 -0500
>>> 
>>>> On Mon, Apr 19, 2010 at 11:43 PM, Kumar Gala <galak@kernel.crashing.org> wrote:
>>>> 
>>>>> spin_event_timeout doesn't make sense for this.  The patch is fine.
>>>> 
>>>> Can you please elaborate on that?  I don't understand why you think
>>>> that.  spin_event_timeout() takes an expression and a timeout, and
>>>> loops over the expression calling cpu_relax(), just like this loop
>>>> does.
>>> 
>>> Indeed it does, Kumar this request seems reasonable.
>> 
>> Are we saying that cpu_relax() is useless and should be removed if we are spinning on a HW register?
> 
> Kumar, take a deep breath and a step back.
> 
> spin_event_timeout() does the cpu_relax() too, that's what Timur is
> trying to tell you.
> 
> The code will be basically identical as far as I can tell.

I understand, its more a sense that we are saying we want to time out for what I consider a catastrophic HW failure.

- k