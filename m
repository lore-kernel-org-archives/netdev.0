From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 09/20] net: sched: convert actions array into
 rcu list
Date: Tue, 1 Aug 2017 06:59:24 +0200
Message-ID: <20170801045924.GB1939@nanopsycho>
References: <20170728144042.6380-1-jiri@resnulli.us>
 <20170728144042.6380-10-jiri@resnulli.us>
 <CAM_iQpWUUM1rj991FM2c2ruOTfgB3ed30AyQo2_KDtj5G8Ojiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Daniel Borkmann <daniel@iogearbox.net>, mlxsw@mellanox.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33498 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751368AbdHAE70 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 00:59:26 -0400
Received: by mail-wm0-f66.google.com with SMTP id q189so1284914wmd.0
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 21:59:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpWUUM1rj991FM2c2ruOTfgB3ed30AyQo2_KDtj5G8Ojiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 31, 2017 at 11:07:13PM CEST, xiyou.wangcong@gmail.com wrote:
>On Fri, Jul 28, 2017 at 7:40 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Currently the actions are stored in array with array size. To traverse
>> this array in fastpath, tcf_tree_lock is taken to protect it. Convert
>> the array into a singly linked list, similar to the filter chains style
>> and allow traversal protected by rcu.
>
>Did you read commit 22dc13c837c33207548c8ee5116 ?
>
>An action can't be shared by multiple filters if you put them
>in a list (no matter singly or double), this is why I use pointers.

Allright. Will check it out.
