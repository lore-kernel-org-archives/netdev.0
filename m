From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net-next 1/1] net sched actions: mirred add support for
 setting Dst MAC address
Date: Sat, 2 Jul 2016 17:38:36 -0400
Message-ID: <5778345C.1060201@mojatatu.com>
References: <1467470065-17613-1-git-send-email-jhs@emojatatu.com>
 <CAM_iQpXpkUo2H=Yndb4u63yKk6jNBbxYynmWtQRGhw6SAVUZrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	nikolay@cumulusnetworks.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:36742 "EHLO
	mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbcGBVij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 17:38:39 -0400
Received: by mail-it0-f44.google.com with SMTP id a5so43585514ita.1
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 14:38:38 -0700 (PDT)
In-Reply-To: <CAM_iQpXpkUo2H=Yndb4u63yKk6jNBbxYynmWtQRGhw6SAVUZrA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-02 12:58 PM, Cong Wang wrote:
> On Sat, Jul 2, 2016 at 7:34 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> Often redirecting or mirroring requires that we set the dstMAC address
>> of the target device. While it is possible to pipe to a pedit action,
>> this patch obsoletes the need for that. This is a justified feature because
>> the dst MAC addresses rewrite is such a common use case.
>
> Maybe, instead of allowing to set arbitrary MAC address, how about
> just allow setting to the MAC address of the target device?

You cant discover the remote MAC address; I have a wire
connected between two machines. I set it to the MAC address
of the remote machine i know of. And there are times I really
want to set it to some arbitrary values (although that is more
test mode than production).

cheers,
jamal

> If so we only need a boolean flag for user-space.
>
> IOW, do we really need such flexibility?
>
