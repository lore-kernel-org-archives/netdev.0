From: Rayagond K <rayagond@vayavyalabs.com>
Subject: Re: iSCSI support in Linux
Date: Tue, 24 Sep 2013 11:00:20 +0530
Message-ID: <CAJ3bTp77Rjsah6oL4=fL9Tn-mLHcjB8UWtjy=hc_11KgLcZK-Q@mail.gmail.com>
References: <CAJ3bTp4SRmg78iU-NNF9WtxBdpXc08T+C+j5zPuEVcaxX-H-kA@mail.gmail.com>
	<CAEc=gqbARiCaaZbvBAAKzEfkVnZL3QN4pDb+5Ljgn5EB8G3ZyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: "Jayamohan.K" <jayamohank@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:56838 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714Ab3IXFaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 01:30:22 -0400
Received: by mail-wi0-f179.google.com with SMTP id hm2so3277742wib.0
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 22:30:20 -0700 (PDT)
In-Reply-To: <CAEc=gqbARiCaaZbvBAAKzEfkVnZL3QN4pDb+5Ljgn5EB8G3ZyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay,

Thanks a lot for your response.

There is seems to be generic iSCSI driver (/drivers/scsi/iscsi_tcp.c).
 So why are we having separate drivers/scsi/be2iscsi ?  is it specific
to emulex storage device ? This point is not clear to me.

I am network driver person, I am not familiar with SCSI/iSCSI. So any
help would be appreciated.

Thanks
Rayagond

On Mon, Sep 23, 2013 at 10:05 PM, Jayamohan.K <jayamohank@gmail.com> wrote:
> Yes, there is support for offloading in Linux (open-iscsi) and it is under
> scsi directory.
>
> One example would be the Emulex driver at  drivers/scsi/be2iscsi
> Disclaimer: I am the Maintainer for it
>
> Thanks
> Jay
>
>
> On Mon, Sep 23, 2013 at 3:54 AM, Rayagond K <rayagond@vayavyalabs.com>
> wrote:
>>
>> Hi All,
>>
>> I am checking iSCSI support in Linux, during the search over internet
>> I got to know that iSCSI standard is implemented in Linux with kernel
>> version 2.6.20 and later. But I didn't understand one thing clearly
>> that is there any NIC offloading features related iSCSI ? if so, is
>> there any support in Linux  for such offloading features ? Any example
>> NIC driver in LXR with iSCSI implementation ?
>>
>>
>> Thanks
>> Rayagond.
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
