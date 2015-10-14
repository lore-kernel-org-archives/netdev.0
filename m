From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next] route: fib_validate_source remove the <=
 RT_SCOPE_HOST test
Date: Thu, 15 Oct 2015 01:25:39 +0800
Message-ID: <CADvbK_cyMbWCWdRm1CBU6vWQ2MypyP2DSwjdvzEaj1_fy-4vJg@mail.gmail.com>
References: <a9569cddcdeb5f0b7d138a22086f76f1b9e5acd5.1444754404.git.lucien.xin@gmail.com>
	<alpine.LFD.2.11.1510132223030.2336@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
	fw@strlen.de
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:33096 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932333AbbJNRZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 13:25:39 -0400
Received: by oiar126 with SMTP id r126so31784480oia.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 10:25:39 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1510132223030.2336@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2015 at 3:24 AM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Wed, 14 Oct 2015, Xin Long wrote:
>
>> commit fe3edf45792a ("ipv4: Remove all RTCF_DIRECTSRC handliing.").
>>
>> Before this commit, we had a tristate:
>> < 0: error
>> 0: ok
>> 1: ok and set RTCF_DIRECTSRC
>>
>> But now we only care about 0 or < 0.
>
>         Not true, __mkroute_input() uses the 'err' result
> to set IPSKB_DOREDIRECT.
>
yeah, I don't understand why err > 0 is necessary to set IPSKB_DOREDIRECT
to send redirects.
FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST, what's that mean?

> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
