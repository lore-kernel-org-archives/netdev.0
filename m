From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Thu, 11 Dec 2014 06:49:20 -0500
Message-ID: <548984C0.2040706@mojatatu.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl> <20141210.233239.472984361665334371.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>,
	Vlad Yasevich <vyasevic@redhat.com>
To: David Miller <davem@davemloft.net>, h.sokolowski@wit.edu.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:37182 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbaLKLtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 06:49:23 -0500
Received: by mail-ie0-f176.google.com with SMTP id tr6so4608880ieb.21
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 03:49:22 -0800 (PST)
In-Reply-To: <20141210.233239.472984361665334371.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/14 23:32, David Miller wrote:
> From: "Hubert Sokolowski" <h.sokolowski@wit.edu.pl>
> Date: Wed, 10 Dec 2014 19:37:01 -0000
>
>> This change restores the semantic that was present
>> before 5e6d243587990a588143b9da3974833649595587
>> "bridge: netlink dump interface at par with brctl"
>> on how ndo_dflt_fdb_dump is called.
>> This semantic is still used for add and del operations
>> so let's keep it consistent.
>> Driver can still call ndo_dflt_fdb_dump from inside
>> its own fdb_dump routine when needed.
>>
>> Signed-off-by: Hubert Sokolowski <h.sokolowski@wit.edu.pl>
>
> Jamal, please review.
>

It wont work. As pointed out by Roopa in
the other email dev->uc/mc will not get dumped with this
change. Vlad will be in a better position to comment.
CCing Vlad.

Hubert, immediate gratification never works on netdev.
I advised you to run the commit tests in at least
2 emails when you contacted me privately before posting.
It would have chewed about 5 minutes of your time.
I am sure it cost Roopa at least 1 hour. And if Dave
had sucked in your innocent looking patch we'd be playing
damage control after which is a lot more expensive.

cheers,
jamal
