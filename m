From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] 8139cp: reset BQL when ring tx ring cleared
Date: Sat, 11 May 2013 19:30:24 -0700
Message-ID: <CAOaVG15T14CO_uTb2XG9Qk+Zgop9DJcRW847iMFrfDu-+-jqvw@mail.gmail.com>
References: <20130511170923.52673453@nehalam.linuxnetplumber.net>
	<20130511.182125.896338102769943216.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David.Woodhouse@intel.com, romieu@fr.zoreil.com,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f48.google.com ([209.85.212.48]:42231 "EHLO
	mail-vb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753545Ab3ELCaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 May 2013 22:30:25 -0400
Received: by mail-vb0-f48.google.com with SMTP id q16so4400760vbe.35
        for <netdev@vger.kernel.org>; Sat, 11 May 2013 19:30:24 -0700 (PDT)
In-Reply-To: <20130511.182125.896338102769943216.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No forgot to refresh.

On Sat, May 11, 2013 at 6:21 PM, David Miller <davem@davemloft.net> wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Sat, 11 May 2013 17:09:23 -0700
>
>> While looking for other problem found this potential issue.
>> When the transmit ring is cleaned out, the Byte Queue Limit values
>> need to be reset.
>>
>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>
> You neither compiled, nor tested this.
