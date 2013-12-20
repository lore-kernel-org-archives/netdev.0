From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 1/4] net_sched: act: clean up notification functions
Date: Thu, 19 Dec 2013 17:39:13 -0800
Message-ID: <CAM_iQpWPSUJJcUFVy6be1qmWd6EcGqK-ZNUkegdg4QsRSBhZRQ@mail.gmail.com>
References: <1387413403-6395-1-git-send-email-xiyou.wangcong@gmail.com>
	<1387413403-6395-2-git-send-email-xiyou.wangcong@gmail.com>
	<CAM_iQpV9Z_K7DRrYLF+hO=_nqEWYoEstuEEGunG1knXe_KB-DQ@mail.gmail.com>
	<52B30560.4090000@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:43855 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756904Ab3LTBjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 20:39:14 -0500
Received: by mail-oa0-f52.google.com with SMTP id h16so2124502oag.25
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 17:39:13 -0800 (PST)
In-Reply-To: <52B30560.4090000@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 6:40 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 12/18/13 19:48, Cong Wang wrote:
>>
>> On Wed, Dec 18, 2013 at 4:36 PM, Cong Wang <xiyou.wangcong@gmail.com>
>> wrote:
>>>
>>> -               if (ret > 0)
>>> -                       return 0;
>>> -               return ret;
>>> -       }
>>> +       else /* delete */
>>> +               ret = tcf_del_notify(net, n, &actions, portid);
>>
>>
>> This piece doesn't look correct. :-) I will fix it.
>>
>
> It is not as trivial and i dont think you have the correct tests to
> vet it.
> Please give me until this weekend to test your other changes
> that are already in.
> I also had some changes i wanted to get in. Then I will review
> and maybe test this as well...


Sure. Meanwhile, I will test this action deletion case and send
the updated patches for you to test in the weekend.

Thanks!
