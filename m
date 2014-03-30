From: Dave Jones <davej@redhat.com>
Subject: Re: new leaks in bridging code.
Date: Sat, 29 Mar 2014 22:47:09 -0400
Message-ID: <20140330024709.GA25793@redhat.com>
References: <533730f2396e8_1c4bb46874192e@209.249.196.67.mail>
 <20140329210102.GA22516@redhat.com>
 <1396146501.2182.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, makita.toshiaki@lab.ntt.co.jp
To: Toshiaki Makita <toshiaki.makita1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14150 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752908AbaC3CrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Mar 2014 22:47:23 -0400
Content-Disposition: inline
In-Reply-To: <1396146501.2182.5.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 30, 2014 at 11:28:21AM +0900, Toshiaki Makita wrote:
 > On Sat, 2014-03-29 at 17:01 -0400, Dave Jones wrote:
 > > yesterdays bridging changes introduced leaks in the exit paths..
 > > 
 > The patch has nothing to do with this memory leak.

Good point, the checker only picked up it as 'new' because of the
additional call to vlan_untag.

 > It has existed since br_allowed_ingress was introduced.
 > I'm working on fixing it.
 > http://marc.info/?t=139598775400004&r=1&w=2

Great! (I'm behind on email so hadn't seen this thread).

Thanks,

	Dave
 
