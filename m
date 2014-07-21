From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: Re: [PATCH V3] netxen: fix ethtool rx_dropped information in ethtool get_ethtool_stats()
Date: Mon, 21 Jul 2014 09:56:08 +0800
Message-ID: <CABawtvNrUqv4R4eacGZmjAm+X-RahurtJiE8XHRKKvptY+wNkw@mail.gmail.com>
References: <1405655009-18975-1-git-send-email-ethan.zhao@oracle.com>
	<C562D0E12CBDE44E8A0CCAB77060096701283AD344@AVMB1.qlogic.org>
	<049BCC6F-0A2E-421A-9873-0B7ED6FFB3AC@gmail.com>
	<20140719101946.GA4319@electric-eye.fr.zoreil.com>
	<CABawtvP4+B_smOyi-=vt56KuUthzHF9L059PXP4ekXA7KPk_Dw@mail.gmail.com>
	<20140719162816.GB7590@electric-eye.fr.zoreil.com>
	<48774298-8C91-42A9-A5F2-4EAB789F356B@gmail.com>
	<20140720180117.GA18951@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Ethan Zhao <ethan.zhao@oracle.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140720180117.GA18951@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

---------- Forwarded message ----------
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Mon, Jul 21, 2014 at 2:01 AM
Subject: Re: [PATCH V3] netxen: fix ethtool rx_dropped information in
ethtool get_ethtool_stats()
To: Ethan Zhao <ethan.kernel@gmail.com>
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>, Ethan Zhao
<ethan.zhao@oracle.com>, Manish Chopra <manish.chopra@qlogic.com>,
Sony Chacko <sony.chacko@qlogic.com>, netdev <netdev@vger.kernel.org>,
linux-kernel <linux-kernel@vger.kernel.org>


Ethan Zhao <ethan.kernel@gmail.com> :
[...]
> you leave us without a tool to track the net core part. Would you like to
> hack the kernel code and rebuild just for peek the dropping packets ?

Search 'dropwatch' on your favorite engine search.

That is a pretty good tool to trace and debug protocal stack when
packet dropping happens. but it is more professional and specific to
kernel kallsyms,
has some bugs to work well on  my box. yet another different tool to
output debug info while not statistic info.

I think drivers output rx dropped has their own reason.

[...]
> More radically, and maybe you should write patches to fix them to keep
> their focus. That is to prove you have principle and always fight for it.

It's 15 years late but it's still a good advice. :o)

Does it work ?

Thanks,
Ethan
--
Ueimor
