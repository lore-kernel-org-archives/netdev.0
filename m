From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Thu, 11 Dec 2014 15:40:05 -0500
Message-ID: <548A0125.2030102@mojatatu.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com> <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl> <5489D53E.5010603@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Hubert Sokolowski <h.sokolowski@wit.edu.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:34935 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758664AbaLKUkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 15:40:08 -0500
Received: by mail-ie0-f170.google.com with SMTP id rd18so5693637iec.1
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 12:40:07 -0800 (PST)
In-Reply-To: <5489D53E.5010603@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/14 12:32, Roopa Prabhu wrote:

>>
> Thanks. yes, that is a problem. And, this mac0 is not a bridge port
> correct ?.
>

Aha. I think this is the key. It is NOT a bridge port. This is why i
was explicit to ask for the commit log tests to be run.

> But, for the same test case, when mac0 is a bridge port, does your patch
> under review make both the entries go away for a bridge port ?.
> (If i understand jamal correctly, this is his concern).

I am interested to see the answer.
More importantly I am hoping Vlad would wake up and say something.

cheers,
jamal
