From: Anand Gurram <anandarao.gurram@gmail.com>
Subject: Re: unregister_netdevice warnings when deleting netns
Date: Tue, 29 Sep 2015 11:55:49 +0530
Message-ID: <CAGGTERmLYm=npbzgauNRY03ULDoeKvzd_3znQB7YxC9MNDF=mA@mail.gmail.com>
References: <CAGGTERmzF7oYABWUR+6UhddpOCtpkciVUMUOU-OcPkQvMznS8Q@mail.gmail.com>
	<alpine.LFD.2.11.1509282202270.7276@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NETDEV <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:34769 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753740AbbI2GZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 02:25:50 -0400
Received: by ykdg206 with SMTP id g206so201458698ykd.1
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 23:25:49 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1509282202270.7276@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Julian, I will check if these two commits work for me.

>I think, they will appear in other stable versions too...

Yes, I saw them in other versions, the fix which is suggested in those
branches didn't work for me.
Hope the above two commits help.

Regards,
Anand

On Tue, Sep 29, 2015 at 12:42 AM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Mon, 28 Sep 2015, Anand Gurram wrote:
>
>> I am currently using kernel version 3.16.7 on a linux switch.
>> While creating and destroying network namespaces I am observing below logs
>> on the console
>> "unregister_netdevice: waiting for lo to become free. Usage count = 1"
>>
>> Can you please suggest and provide instructions on how to debug this issue.
>> If any fix already available can you please point me to the link.
>
>         There are two commits from Linux 4.2 that may help:
>
> commit e9e4dd3267d0 ("net: do not process device backlog during unregistration")
> commit 2c17d27c36dc ("net: call rcu_read_lock early in process_backlog")
>
>         For now I see them only in 3.2.71+ and 3.12.48+.
> I think, they will appear in other stable versions too...
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
