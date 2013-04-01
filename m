From: Ani Sinha <linuxdev@anirban.org>
Subject: Re: RX/dropped counter values for tagged packets
Date: Sun, 31 Mar 2013 18:24:04 -0700
Message-ID: <CAOQZsUj71vX-71S4WhJUmerh5VhtheacXVCkGKpyFEHTG9WBgA@mail.gmail.com>
References: <CAOxq_8OrE6=XtJ9TDbL7NH9313-WutZPZP8=cRBH7pVUdBDvCg@mail.gmail.com>
	<CAOxq_8OBcHktjmkwiz2j=DXDAdNx3t7D_nTmDtuJudfs49VNrg@mail.gmail.com>
	<1364708664.5113.139.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ani Sinha <ani@aristanetworks.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:51518 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753004Ab3DABYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Mar 2013 21:24:06 -0400
Received: by mail-ie0-f177.google.com with SMTP id tp5so1864633ieb.8
        for <netdev@vger.kernel.org>; Sun, 31 Mar 2013 18:24:05 -0700 (PDT)
In-Reply-To: <1364708664.5113.139.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 30, 2013 at 10:44 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> I don't know, I am not reading this code like you, I see no problem.
>
> If vlan_do_receive() return true, we "goto another_round" to deliver the
> packt to vlan device.
>
> vlan_do_receive() doesn't deliver the packet at all. It only prepares
> the "another_round"


yes, I am with you on this. But let's focus on this "another_round" code.

>
> So if packet is delivered to vlan, we don't increment rx_dropped.

So in "another_round", if pt_prev is null at the end of the function
(not sure if this can actually happen in reality, but from the code it
looks like a possibility), the dropped counts will get incremented.


Does that make sense?

cheers,
ani
