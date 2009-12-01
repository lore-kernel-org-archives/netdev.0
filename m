From: David Miller <davem@davemloft.net>
Subject: Re: NULL pointer dereference at
 2.6.32-rc8:net/ipv4/ip_fragment.c:566
Date: Mon, 30 Nov 2009 21:01:08 -0800 (PST)
Message-ID: <20091130.210108.257061035.davem@davemloft.net>
References: <523e55a00911250152n773f2cbeu9251180c44f0b9a@mail.gmail.com>
	<20091201043759.GA22655@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: firefighterblu3@gmail.com, linux-kernel@vger.kernel.org,
	david@blue-labs.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751940AbZLAFBF@vger.kernel.org>
In-Reply-To: <20091201043759.GA22655@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 1 Dec 2009 12:37:59 +0800

> David Ford <firefighterblu3@gmail.com> wrote:
>>
>> hmm.  that shows a patch of code which is just prior to ip_defrag(), i.e.:
>> 
>>    565 out_fail:
>>    566         IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_REASMFAILS);
> 
> Looks like a namespace problem.
> 
> Please open a bug report on bugzilla.kernel.org to ensure that
> this is tracked.

Herbert, David posted a patch to fix this which went into my tree the
other day and now has reached Linus's tree as well.
