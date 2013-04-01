From: Ani Sinha <linuxdev@anirban.org>
Subject: Re: RX/dropped counter values for tagged packets
Date: Sun, 31 Mar 2013 21:44:24 -0700
Message-ID: <CAOQZsUhi_PELddHQ66EOk-_pZWev7f1Ohj8f-PvFKcDuQgEL=A@mail.gmail.com>
References: <CAOxq_8OrE6=XtJ9TDbL7NH9313-WutZPZP8=cRBH7pVUdBDvCg@mail.gmail.com>
	<CAOxq_8OBcHktjmkwiz2j=DXDAdNx3t7D_nTmDtuJudfs49VNrg@mail.gmail.com>
	<1364708664.5113.139.camel@edumazet-glaptop>
	<CAOQZsUj71vX-71S4WhJUmerh5VhtheacXVCkGKpyFEHTG9WBgA@mail.gmail.com>
	<1364785789.5113.141.camel@edumazet-glaptop>
	<CAOQZsUjbx9fHtjexmpfGCETRjVJU7QOBJcng6ndT1nFaZKmf5w@mail.gmail.com>
	<1364787794.5113.147.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ani Sinha <ani@aristanetworks.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:45370 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756553Ab3DAEoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 00:44:25 -0400
Received: by mail-ie0-f171.google.com with SMTP id e14so2021048iej.16
        for <netdev@vger.kernel.org>; Sun, 31 Mar 2013 21:44:25 -0700 (PDT)
In-Reply-To: <1364787794.5113.147.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 31, 2013 at 8:43 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2013-03-31 at 20:17 -0700, Ani Sinha wrote:
>
>> Correct. Now if you combine the two cases, we increment the rx count
>> for tagged packets in  vlan_do_receive() and then in "another_round",
>> if pt_prev is null, we also increment the rx_dropped.
>>
>
> Thats the way its done in a NIC driver.
>
> We increment rx_{bytes|packets} counters before giving the packet to the
> upper stack.
>
> Then the stack might drop the packet and increment rx_dropped.
>

thanks for the clarification. So basically what this means is that
from the numbers reported by ifconfig for example, rx-dropped is the
true rx value.
