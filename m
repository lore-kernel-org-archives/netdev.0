From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Wed, 20 Nov 2013 09:40:22 -0800
Message-ID: <1384969222.10637.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site>
	 <87y54u59zq.fsf@natisbad.org> <20131112083633.GB10318@1wt.eu>
	 <87a9hagex1.fsf@natisbad.org> <20131112100126.GB23981@1wt.eu>
	 <87vbzxd473.fsf@natisbad.org> <20131113072257.GB10591@1wt.eu>
	 <20131117141940.GA18569@1wt.eu>
	 <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131120171227.GG8581@1wt.eu> <20131120173436.GK8581@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org, Arnaud Ebalard <arno@natisbad.org>,
	edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:60711 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753145Ab3KTRkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 12:40:24 -0500
Received: by mail-pd0-f181.google.com with SMTP id p10so2292372pdj.12
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 09:40:23 -0800 (PST)
In-Reply-To: <20131120173436.GK8581@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-20 at 18:34 +0100, Willy Tarreau wrote:

> One important point, I was looking for the other patch you pointed
> in this long thread and finally found it :
> 
> > So
> > http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=98e09386c0ef4dfd48af7ba60ff908f0d525cdee
> > 
> > restored this minimal amount of buffering, and let the bigger amount for
> > 40Gb NICs ;)
> 
> This one definitely restores original performance, so it's a much better
> bet in my opinion :-)

I don't understand. I thought you were using this patch.

I guess we are spending time on a already solved problem.
