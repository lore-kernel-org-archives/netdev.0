From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Mon, 9 Jul 2012 13:13:26 +0800
Message-ID: <CACVXFVP6DAfrRsYT_=uTi4C35SQAic9=KTyetAz-cnZO+es35w@mail.gmail.com>
References: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
	<1341474192.2583.3299.camel@edumazet-glaptop>
	<CACVXFVNxcdEYd-KmkUe9=8+x_9s-ZVuoM=FfZ=QXa7w_qRiTnw@mail.gmail.com>
	<1341477192.2583.3415.camel@edumazet-glaptop>
	<CACVXFVPTXB7t=zwkm+HTgDaF3bA02bzff_52S+UAr51PfpvpCg@mail.gmail.com>
	<1341481760.2583.3579.camel@edumazet-glaptop>
	<CACVXFVNZ=64+=w1ZapXeXq7oYz0OBbBRLuH8rNSeDHyz7zGOZw@mail.gmail.com>
	<1341484919.2583.3688.camel@edumazet-glaptop>
	<CACVXFVPksMd8CGZWEGBXBXB5NZCg3QOZreOLavkV-Z2pjE-M_A@mail.gmail.com>
	<1341500196.2583.4222.camel@edumazet-glaptop>
	<CACVXFVMgwbz1fDC=_9dhVUZ_btiO3fNdFiuXm-7gMXFUAMtmsw@mail.gmail.com>
	<1341550714.3265.44.camel@edumazet-glaptop>
	<1341551764.3265.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:63119 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073Ab2GIFN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 01:13:27 -0400
Received: by obbuo13 with SMTP id uo13so19997276obb.19
        for <netdev@vger.kernel.org>; Sun, 08 Jul 2012 22:13:26 -0700 (PDT)
In-Reply-To: <1341551764.3265.47.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 6, 2012 at 1:16 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2012-07-06 at 06:58 +0200, Eric Dumazet wrote:
>> On Fri, 2012-07-06 at 08:45 +0800, Ming Lei wrote:
>>
>> > Unfortunately, the patch still hasn't any improvement on the transmit
>> > performance of beagle-xm.
>>
>> Ah yes, I need to change usbnet as well to be able to fully recycle the
>> big skbs allocated in turbo mode.
>>
>> Right now they are constantly allocated/freed and this sucks if SLAB
>> wants to check poison bytes in debug mode.
>
> In the mean time, you also can use the following patch I have to polish,
> but this should give you a nice boost, since the big skb skb->head wont
> be checked by SLAB debug :

Unfortunately, the patch makes the result of the same test  worsen than
without the patch, :-(


Thanks,
-- 
Ming Lei
