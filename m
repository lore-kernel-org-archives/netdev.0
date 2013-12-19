From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next 1/4] net_sched: act: clean up notification functions
Date: Thu, 19 Dec 2013 09:40:32 -0500
Message-ID: <52B30560.4090000@mojatatu.com>
References: <1387413403-6395-1-git-send-email-xiyou.wangcong@gmail.com>	<1387413403-6395-2-git-send-email-xiyou.wangcong@gmail.com> <CAM_iQpV9Z_K7DRrYLF+hO=_nqEWYoEstuEEGunG1knXe_KB-DQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:35473 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753557Ab3LSOke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 09:40:34 -0500
Received: by mail-ie0-f170.google.com with SMTP id qd12so1411890ieb.1
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 06:40:33 -0800 (PST)
In-Reply-To: <CAM_iQpV9Z_K7DRrYLF+hO=_nqEWYoEstuEEGunG1knXe_KB-DQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/18/13 19:48, Cong Wang wrote:
> On Wed, Dec 18, 2013 at 4:36 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> -               if (ret > 0)
>> -                       return 0;
>> -               return ret;
>> -       }
>> +       else /* delete */
>> +               ret = tcf_del_notify(net, n, &actions, portid);
>
> This piece doesn't look correct. :-) I will fix it.
>

It is not as trivial and i dont think you have the correct tests to
vet it.
Please give me until this weekend to test your other changes
that are already in.
I also had some changes i wanted to get in. Then I will review
and maybe test this as well...

cheers,
jamal
