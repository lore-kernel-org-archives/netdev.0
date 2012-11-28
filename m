From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: performance regression on HiperSockets depending on MTU size
Date: Wed, 28 Nov 2012 13:31:04 +0800
Message-ID: <CAM_iQpVv=__3kcfjq3rdy25r68PivBd41msSV97=5oXLY+cXNQ@mail.gmail.com>
References: <20121126153242.GA61652@tuxmaker.boeblingen.de.ibm.com>
	<1353946351.30446.1779.camel@edumazet-glaptop>
	<k91m5l$77a$1@ger.gmane.org>
	<1353998800.7553.873.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:52028 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859Ab2K1FbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 00:31:06 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so6509006pad.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 21:31:04 -0800 (PST)
In-Reply-To: <1353998800.7553.873.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 27, 2012 at 2:46 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2012-11-27 at 06:21 +0000, Cong Wang wrote:
>
>> Eric,
>>
>> Do you have a full list of such commits? I am trying to backport TSQ
>> to 2.6.32, and of course I don't want to miss these commits either.
>
> I dont think there are other known issues.
>
> mlx4 had a 'problem' because only recently we removed the skb_orphan()
> call it used to do in its start_xmit() function.
>
> I remember David had to revert BQL on NIU driver, but NIU does the
> skb_orphan() call as well so TSQ is basically disabled.
>
>


Good news! Thanks!
