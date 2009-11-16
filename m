From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 2/2] act_mirred: optimization
Date: Mon, 16 Nov 2009 17:40:40 +0800
Message-ID: <412e6f7f0911160140v7250da63h43d05da3a6aa7935@mail.gmail.com>
References: <412e6f7f0911160056k6718dd55w6dcd7c7e673459c4@mail.gmail.com>
	 <1258363789.3251.30.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:44125 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbZKPJkf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 04:40:35 -0500
Received: by pzk1 with SMTP id 1so2665741pzk.33
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 01:40:41 -0800 (PST)
In-Reply-To: <1258363789.3251.30.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 16, 2009 at 5:29 PM, jamal <hadi@cyberus.ca> wrote:
> On Mon, 2009-11-16 at 16:56 +0800, Changli Gao wrote:
>> act_mirred: optimization.
>>
>> 1. move checking if eaction is valid in tcf_mirred_init()
>
> This one looks ok - and like i mentioned earlier it should be
> a patch on its own. Can you please make it a separate patch,
> test it and add my signed-off?
>
>> 2. fixed a race condition between __dev_get_by_index() and dev_get()
>
> This one i am not sure. What broke to motivate the patch?
> Also note: if you moved things into _init() I am pretty sure
> we have at least rtnl held.
>

OK, I'll use the old __dev_get_by_index() and post the patch with your
signed-off again. Thanks.



--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
