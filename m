From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: Fw: [Bug 70071] New: Sending netconsole messages over a bridged
 network interface doesn't work anymore
Date: Thu, 06 Feb 2014 17:52:17 +0900
Message-ID: <52F34D41.8000704@lab.ntt.co.jp>
References: <20140205141539.450095fa@samsung-9>	<52F30863.7000206@lab.ntt.co.jp>	<CAHA+R7Pf1q7+xyqpwmGPToa0fTGn6dmukLvyncWwYAP-F_JvLg@mail.gmail.com>	<52F3214C.4060308@lab.ntt.co.jp> <CAHA+R7Ork+gER_v=YhQCSDO9N=aokXiSiMUWwD3aMSv2YaZJ4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:58966 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754961AbaBFIwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 03:52:25 -0500
In-Reply-To: <CAHA+R7Ork+gER_v=YhQCSDO9N=aokXiSiMUWwD3aMSv2YaZJ4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2014/02/06 15:49), Cong Wang wrote:
> On Wed, Feb 5, 2014 at 9:44 PM, Toshiaki Makita
> <makita.toshiaki@lab.ntt.co.jp> wrote:
>> Tested this patch with latest net-tree and netconsole works with it.
>> But I thinks it is better to move that "if" to br_add_if() because if we
>> don't have npinfo, we don't have to alloc p->np in br_add_if(), right?
>>
> 
> Hmm, we shouldn't handle netpoll-specific code inside br_add_if(),
> we probably need the attached patch instead. Please give it
> a try, or I will test it tomorrow, it's too late here.
> 

I tested whether netconsole works and whether it can be built
with/without CONFIG_NET_POLL_CONTROLLER, and couldn't find any problem.
This looks good to me.

Thanks,
Toshiaki Makita
