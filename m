From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next 3/3] team: replicate options on register
Date: Thu, 17 Nov 2011 10:57:30 +0100
Message-ID: <20111117095729.GA2093@minipsycho>
References: <1321477749-1877-1-git-send-email-jpirko@redhat.com>
 <1321477749-1877-4-git-send-email-jpirko@redhat.com>
 <1321518736.3274.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	andy@greyhouse.net, fbl@redhat.com, jzupka@redhat.com,
	ivecera@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2553 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756240Ab1KQJ5g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 04:57:36 -0500
Content-Disposition: inline
In-Reply-To: <1321518736.3274.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Nov 17, 2011 at 09:32:16AM CET, eric.dumazet@gmail.com wrote:
>Le mercredi 16 novembre 2011 =E0 22:09 +0100, Jiri Pirko a =E9crit :
>
>> +
>> +int team_options_register(struct team *team,
>> +			  const struct team_option *option,
>> +			  size_t option_count)
>>  {
>>  	int i;
>> +	struct team_option *dst_opts[option_count];
>> +	int err;
>
>This kind of construct will trigger static analyzer alerts...


I thought this is ok to do in kernel. Should I replace that with
kmalloc/kfree?

>
>
>
>
