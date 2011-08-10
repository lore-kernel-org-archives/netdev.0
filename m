From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] slip: fix NOHZ local_softirq_pending 08 warning
Date: Wed, 10 Aug 2011 16:33:28 +0200
Message-ID: <4E4296B8.1090806@hartkopp.net>
References: <CAKh5naYrNPG3UO02VzG13QUP-SOP8-Td+O0G5LAr-+npduP49A@mail.gmail.com>	<4E416951.4020207@hartkopp.net>	<CAKh5naayzp3ANwnE2Y9U2LEaiWNoZAuT3aOQbRYdoB5uNdrOPw@mail.gmail.com> <20110810102824.4c4eaefe@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>, matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:20616 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750Ab1HJOdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 10:33:50 -0400
In-Reply-To: <20110810102824.4c4eaefe@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10.08.2011 11:28, Alan Cox wrote:
>>   2) From tty_flip_buffer_push() which schedules the flush_to_ldisc to
>> work or calls it directly if the tty->low_latency set.
>>
>> So the only thing we must take into account that with tty->low_latency
>> set we can be in IRQ context when doing with netif_rx_ni(). But if we
> 
> A driver is not permitted to directly call into flush_to_ldisc from an
> interrupt so that case doesn't happen.
> 

Thanks to both of you for the explanation!

I'll send a patch for slcan.c then.

Best regards,
Oliver
