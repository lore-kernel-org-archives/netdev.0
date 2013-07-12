From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: updates to syncookies - timestamps not needed any more (freebsd)
Date: Fri, 12 Jul 2013 08:59:06 +0200
Message-ID: <CAFLxGvzihGSgNZ5NOJxMN2pgQiCPXgJSRjVCcj3Ncfw3oe_YLA@mail.gmail.com>
References: <20130708160421.GA9763@order.stressinduktion.org>
	<20130711.165726.2168148122875413191.davem@davemloft.net>
	<20130712014138.GD12611@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f175.google.com ([209.85.220.175]:44173 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756788Ab3GLG7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 02:59:07 -0400
Received: by mail-vc0-f175.google.com with SMTP id hr11so7338346vcb.20
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 23:59:07 -0700 (PDT)
In-Reply-To: <20130712014138.GD12611@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 12, 2013 at 3:41 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Thu, Jul 11, 2013 at 04:57:26PM -0700, David Miller wrote:
>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Date: Mon, 8 Jul 2013 18:04:21 +0200
>>
>> > Interesting patch by Andre Opperann of FreeBSD:
>> > <http://lists.freebsd.org/pipermail/freebsd-net/2013-July/035999.html>
>>
>> Interesting work, but outside of the change of hash function I'm not so
>> sure.  The whole reason we went to the timestamp field was to eliminate
>> the coarse tables.
>>
>> I understand that he claims that %99.99 of connections are handled by
>> the values he has chosen, but this is still a step backwards in my
>> opinion.
>
> If I understood this thread[0] correctly, it seems Windows 8 might not
> enable TCP timestamps by default? I can not verify, I currently have
> no Windows installations near me. That would mean, linux does, too,
> fall back to an unscaled window connection as soon as syncookies kick in
> (but we would not end up with an unsynchronized window scale option).

My Windows 8 workstations here have it disabled by default.

--
Thanks,
//richard
