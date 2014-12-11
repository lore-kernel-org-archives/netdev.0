From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Thu, 11 Dec 2014 09:32:46 -0800
Message-ID: <5489D53E.5010603@cumulusnetworks.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com> <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@mojatatu.com>
To: Hubert Sokolowski <h.sokolowski@wit.edu.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:54377 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932581AbaLKRct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 12:32:49 -0500
In-Reply-To: <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/14, 9:06 AM, Hubert Sokolowski wrote:
> My apologies for sending again, I forgot to include a sample output you asked.
>
>> Also, if i hear your concern correctly, for bridge ports that implement
>> ndo_fdb_dump, with commit 5e6d243587990a588143b9da3974833649595587, we
>> will get two entries for each 'self' entry above.
>> Can you also paste sample output for that ?.
>>
> [root@silpixa00378825 ~]# bridge fdb show brport mac0
> 33:33:00:00:00:01 self permanent
> 33:33:00:00:00:01 self permanent
>
>
Thanks. yes, that is a problem. And, this mac0 is not a bridge port 
correct ?.

But, for the same test case, when mac0 is a bridge port, does your patch 
under review make both the entries go away for a bridge port ?.
(If i understand jamal correctly, this is his concern).
