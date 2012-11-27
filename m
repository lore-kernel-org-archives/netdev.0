From: Ling Ma <ling.ma.program@gmail.com>
Subject: Re: [PATCH RFC] [INET]: Get cirtical word in first 64bit of cache line
Date: Tue, 27 Nov 2012 21:48:42 +0800
Message-ID: <CAOGi=dPQWC8hgt4jhMEHcVPb6j+jMTguNAchiLjdvvHjarCW4Q@mail.gmail.com>
References: <1353900555-5966-1-git-send-email-ling.ma.program@gmail.com>
	<1353912241.30446.1257.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1353912241.30446.1257.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> networking patches should be sent to netdev.
>
> (I understand this patch is more a generic one, but at least CC netdev)
Ling: OK, this is my first inet patch, I will send to netdev later.

> You give no performance numbers for this change...
Ling: after I get machine, I will send out test result.

> I never heard of this CWF/ER, where are the official Intel documents
> about this, and what models really benefit from it ?
Ling:
Arm implemented it.
http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.ddi0388f/Caccifbd.html
AMD also used it.
http://classes.soe.ucsc.edu/cmpe202/Fall04/papers/opteron.pdf

> Also, why not moving skc_net as well ?
>
> BTW, skc_daddr & skc_rcv_saddr are 'critical' as well, we use them in
> INET_MATCH()
Ling: in the looking-up routine, hash value is the most important key,
if it is matched,  the other values have most possibility to be
satisfied, and CFW is limited by memory bandwidth(64bit usually), so
we only move hash value as critical first word.

Thanks
Ling
