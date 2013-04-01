From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RX/dropped counter values for tagged packets
Date: Sun, 31 Mar 2013 20:09:49 -0700
Message-ID: <1364785789.5113.141.camel@edumazet-glaptop>
References: <CAOxq_8OrE6=XtJ9TDbL7NH9313-WutZPZP8=cRBH7pVUdBDvCg@mail.gmail.com>
	 <CAOxq_8OBcHktjmkwiz2j=DXDAdNx3t7D_nTmDtuJudfs49VNrg@mail.gmail.com>
	 <1364708664.5113.139.camel@edumazet-glaptop>
	 <CAOQZsUj71vX-71S4WhJUmerh5VhtheacXVCkGKpyFEHTG9WBgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ani Sinha <ani@aristanetworks.com>, netdev@vger.kernel.org
To: Ani Sinha <linuxdev@anirban.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:58384 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755988Ab3DADJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Mar 2013 23:09:53 -0400
Received: by mail-pa0-f54.google.com with SMTP id fa10so1090972pad.41
        for <netdev@vger.kernel.org>; Sun, 31 Mar 2013 20:09:52 -0700 (PDT)
In-Reply-To: <CAOQZsUj71vX-71S4WhJUmerh5VhtheacXVCkGKpyFEHTG9WBgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-31 at 18:24 -0700, Ani Sinha wrote:

> So in "another_round", if pt_prev is null at the end of the function
> (not sure if this can actually happen in reality, but from the code it
> looks like a possibility), the dropped counts will get incremented.
> 

If packets are dropped, we increment rx_dropped.

Nothing special with vlan, its the same with non tagged packets.

So far so good. 
