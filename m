From: Karl Hiramoto <karl@hiramoto.org>
Subject: Re: [PATCH v4 1/9] atm: propagate signal changes via notifier
Date: Fri, 09 Jul 2010 08:36:03 +0200
Message-ID: <4C36C353.9080501@hiramoto.org>
References: <1278578095-25324-1-git-send-email-karl@hiramoto.org>	<1278578095-25324-2-git-send-email-karl@hiramoto.org> <20100708.214745.48520104.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdcaib.dreamhost.com ([208.97.132.81]:45513 "EHLO
	homiemail-a25.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751333Ab0GIGgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:36:08 -0400
In-Reply-To: <20100708.214745.48520104.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On 07/09/2010 06:47 AM, David Miller wrote:
> From: Karl Hiramoto <karl@hiramoto.org>
> Date: Thu,  8 Jul 2010 10:34:47 +0200
>
>> +
>> +/*
>> + * atm_dev_signal_change
>> + *
>> + * Propagate lower layer signal change in atm_dev->signal to netdevice.
>> + * The event will be sent via a notifier call chain.
>> + */
> I said to format comments:
>
> /* Like
>  * this.
>  */
>
> not:
>
> /*
>  * Like
>  * this.
>  */
>
> Honestly, I don't know how I can be more clear about this :-)


Ok, fixing it,  but there are 100's of occurences in net/ like i had it. :-)

--
Karl
