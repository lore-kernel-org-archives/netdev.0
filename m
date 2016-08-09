From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 5/5] net_sched: convert tcf_exts from list to flex_array
Date: Tue, 9 Aug 2016 11:02:08 -0700
Message-ID: <CAM_iQpUT1sqK_QiC-dbWGGCBNSjdQbqr117_Fx2oxnh14=rnTA@mail.gmail.com>
References: <1470689209-17682-1-git-send-email-xiyou.wangcong@gmail.com>
 <1470689209-17682-6-git-send-email-xiyou.wangcong@gmail.com> <CAPcc5PhMHVSFoQVoF7u0Kcn0Cn=kLWB+Hr3bZT8f2rgk5pNfOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:36632 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932257AbcHISCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 14:02:30 -0400
Received: by mail-io0-f173.google.com with SMTP id b62so18965709iod.3
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 11:02:30 -0700 (PDT)
In-Reply-To: <CAPcc5PhMHVSFoQVoF7u0Kcn0Cn=kLWB+Hr3bZT8f2rgk5pNfOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 9, 2016 at 1:03 AM, Amir Vadai <amirva@gmail.com> wrote:
>
>> -#define tc_single_action(_exts) \
>> -       (list_is_singular(&(_exts)->actions))
>> +#define tc_no_actions(_exts)  (&(_exts)->nr_actions == 0)
>> +#define tc_single_action(_exts) (&(_exts)->nr_actions == 1)
>
> Should remove the '&' here.

Good catch! I even didn't notice the '&' there. :-/

I will wait for Jamal's comments before sending v2.

Thanks.
