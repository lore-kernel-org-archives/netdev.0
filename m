From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v7 4/7 RFC] TCPCT part 1d: define TCP cookie
 option, extend existing struct's
Date: Sat, 21 Nov 2009 23:53:26 -0500
Message-ID: <4B08C3C6.8010601@gmail.com>
References: <4B06A1FF.8000202@gmail.com>	<4B06A9D4.8070007@gmail.com> <20091120.092515.126988512.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:58019 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754376AbZKVExX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 23:53:23 -0500
Received: by yxe17 with SMTP id 17so3943217yxe.33
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2009 20:53:29 -0800 (PST)
In-Reply-To: <20091120.092515.126988512.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: William Allen Simpson <william.allen.simpson@gmail.com>
> Date: Fri, 20 Nov 2009 09:38:12 -0500
> 
>>  static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
>>  {
>> -	rx_opt->tstamp_ok = rx_opt->sack_ok = rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
>> +	rx_opt->tstamp_ok = rx_opt->sack_ok = 0;
>> +	rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
>> +	rx_opt->cookie_plus = 0;
>>  }
>>  
> 
> Why not get the coding style correct wrt. long lines in patch #3 where
> you initially added this function, rather than fixing it here as you
> add the new ->cookie_plus assignment?
> 
Documentation/SubmittingPatches at 619:

One significant exception is when moving code from one file to
another -- in this case you should not modify the moved code at all in
the same patch which moves it.  This clearly delineates the act of
moving the code and your changes.  This greatly aids review of the
actual differences and allows tools to better track the history of
the code itself.
