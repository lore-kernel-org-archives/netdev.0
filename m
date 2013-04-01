From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RX/dropped counter values for tagged packets
Date: Sun, 31 Mar 2013 20:43:14 -0700
Message-ID: <1364787794.5113.147.camel@edumazet-glaptop>
References: <CAOxq_8OrE6=XtJ9TDbL7NH9313-WutZPZP8=cRBH7pVUdBDvCg@mail.gmail.com>
	 <CAOxq_8OBcHktjmkwiz2j=DXDAdNx3t7D_nTmDtuJudfs49VNrg@mail.gmail.com>
	 <1364708664.5113.139.camel@edumazet-glaptop>
	 <CAOQZsUj71vX-71S4WhJUmerh5VhtheacXVCkGKpyFEHTG9WBgA@mail.gmail.com>
	 <1364785789.5113.141.camel@edumazet-glaptop>
	 <CAOQZsUjbx9fHtjexmpfGCETRjVJU7QOBJcng6ndT1nFaZKmf5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ani Sinha <ani@aristanetworks.com>, netdev@vger.kernel.org
To: Ani Sinha <linuxdev@anirban.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:34414 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756008Ab3DADnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Mar 2013 23:43:18 -0400
Received: by mail-pd0-f178.google.com with SMTP id w11so4788pde.23
        for <netdev@vger.kernel.org>; Sun, 31 Mar 2013 20:43:17 -0700 (PDT)
In-Reply-To: <CAOQZsUjbx9fHtjexmpfGCETRjVJU7QOBJcng6ndT1nFaZKmf5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-31 at 20:17 -0700, Ani Sinha wrote:

> Correct. Now if you combine the two cases, we increment the rx count
> for tagged packets in  vlan_do_receive() and then in "another_round",
> if pt_prev is null, we also increment the rx_dropped.
> 

Thats the way its done in a NIC driver.

We increment rx_{bytes|packets} counters before giving the packet to the
upper stack.

Then the stack might drop the packet and increment rx_dropped.
