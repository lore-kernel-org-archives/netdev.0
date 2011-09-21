From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: TCP_DELACK_MIN vs TCP_ATO_MIN
Date: Wed, 21 Sep 2011 18:28:19 +0300
Message-ID: <CAEnQRZBdoPBn1bidga5c89n-Oru2JzrQa9bTj_tBG4HxS33PyA@mail.gmail.com>
References: <CAEnQRZAObcdhikY6GzG3mC1KZjgK8Xp5LzNetczmZP=BRPqN6w@mail.gmail.com>
	<CALJfu6MnV0se8YCTWt65=_4PcOhKsbvUgRmaNxbjf7La+4ar4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org,
	kernelnewbies <kernelnewbies@kernelnewbies.org>
To: rohan puri <rohan.puri15@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34627 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab1IUP2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 11:28:21 -0400
Received: by wyg34 with SMTP id 34so2019032wyg.19
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2011 08:28:20 -0700 (PDT)
In-Reply-To: <CALJfu6MnV0se8YCTWt65=_4PcOhKsbvUgRmaNxbjf7La+4ar4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Now the default value is of both the macros is same.
>
> But if you want to make delayed ack timeout configurable, then I think you
> should give proc interface for TCP_DELACK_MIN.

Thanks Rohan. Then also I have to export TCP_DELACK_MAX since I think
ato cannot grow over this value.

thanks,
Daniel.
