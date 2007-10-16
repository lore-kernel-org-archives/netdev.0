From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Will RFC1146 (tcp alternative checksum options) be implemented
 in Linux tcp stack ?
Date: Mon, 15 Oct 2007 20:38:15 -0700
Message-ID: <47143227.3060501@linux-foundation.org>
References: <887901.30138.qm@web55205.mail.re4.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yanping Du <ypdu2001@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48398 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757681AbXJPDiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 23:38:00 -0400
In-Reply-To: <887901.30138.qm@web55205.mail.re4.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yanping Du wrote:
> Hi,
>
>   We found the standard 16-bit tcp checksum is not
> strong enough in some cases. Is there any roadmap on
> implementing RFC1146 (tcp alternative checksum
> options) in Linux tcp stack ? If yes, how soon will
> that be in ?
>
> Please kindly copy reply to my email address as I've
> not subscribed the netdev@ mailing list at present.
>
>   http://www.faqs.org/rfcs/rfc1146.html
>
>   

You would of course lose all the hardware offload of checksumming since
no hardware supports alternative checksums.
