From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: tc related lockdep warning.
Date: Mon, 25 Sep 2006 15:05:05 +0200
Message-ID: <20060925130505.GB1592@ff.dom.local>
References: <1159188473.5301.68.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dave Jones <davej@redhat.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:32669 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S932079AbWIYNAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 09:00:51 -0400
To: hadi@cyberus.ca
Content-Disposition: inline
In-Reply-To: <1159188473.5301.68.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25-09-2006 14:47, jamal wrote:
> On Mon, 2006-25-09 at 14:43 +0200, Jarek Poplawski wrote:
> 
>> It's probably 2.6.18 and should change a little now (git4) but
>> IMHO main problem stays: it looks tcf_act_police_locate in
>> act_police.c was preempted in read_lock (tcf_police_lookup)
>> - now the same is possible in tcf_hash_lookup. So maybe
>> read_lock_bh will help?
>>
> 
> Yes, that looks plausible. Can you try making those changes and see if
> the warning is gone?

I hope you are asking Dave Jones... 

Jarek P. 
