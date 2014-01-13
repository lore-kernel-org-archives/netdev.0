From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: suspicious RCU usage in net/ipv4/ip_tunnel.c:80
Date: Mon, 13 Jan 2014 00:20:33 -0800
Message-ID: <1389601233.31367.213.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHA+R7PAyR_cJ9_9nfUBc0U9o-U=gCV+sN_VYbHwgq-QdoEVzQ@mail.gmail.com>
	 <1389403281.31367.171.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7OMM9ndy4hXF4rJBsA_Rb0KZ-MonuvE++wgzO_oMbo+eQ@mail.gmail.com>
	 <1389548697.31367.184.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7Pe_pGFw5cA3v_RnGvOurAykJNVH5=DeeEVHG84faWi2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:41216 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbaAMIUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 03:20:35 -0500
Received: by mail-pd0-f174.google.com with SMTP id w10so2434353pde.19
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 00:20:35 -0800 (PST)
In-Reply-To: <CAHA+R7Pe_pGFw5cA3v_RnGvOurAykJNVH5=DeeEVHG84faWi2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-01-12 at 22:36 -0800, Cong Wang wrote:
> > Please read rcu_dereference_protected() documentation in
> > include/linux/rcupdate.h
> 
> I did before I replied.



> 
> >
> > Also you can run sparse, with CONFIG_SPARSE_RCU_POINTER=y in
> > your .config
> >
> > make C=2 net/ipv4/ip_tunnel.o
> >
> > And then you'll know the answer to this question.
> >
> 
> Sounds like it is only to shut up a sparse warning, then its name
> is misleading, we clearly don't dereference it here.

Historical reasons, you should have been there when Paul invented the
name and lazy people like us let him do so !

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=b62730baea32f86fe91a7930e4b7ee8d82778b79

You are lucky, there is plenty of documentation, maybe too much..
