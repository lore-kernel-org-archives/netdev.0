From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: Re: [PATCH] mac80211: use list_move instead of list_del/list_add
Date: Thu, 6 Sep 2012 21:57:53 +0800
Message-ID: <CAPgLHd_Vwr2oGWEGi_Ey5WcVz+XKT8yh76CYDNiy1d73rk2cbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linville@tuxdriver.com, yongjun_wei@trendmicro.com.cn,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:33499 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752742Ab2IFN5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 09:57:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/2012 05:56 PM, Johannes Berg wrote:

Hi Johannes,

> On Thu, 2012-09-06 at 13:20 +0800, Wei Yongjun wrote:
>> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>>
>> Using list_move() instead of list_del() + list_add().
>>
>> spatch with a semantic match is used to found this problem.
>> (http://coccinelle.lip6.fr/)
>>
>> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> Applied. FWIW, I don't think it's really a "problem" rather than a
> simplification or something like that, but anyway.

That is right, I will change the patch description if I send some other
patchs like this cleanup.

Thanks,
Yongjun Wei

>
> johannes
>
>
>
