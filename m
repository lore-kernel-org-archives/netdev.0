From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: net-next build failure due to 16e5cc64?
Date: Tue, 1 Mar 2016 13:41:19 -0500
Message-ID: <20160301184119.GS16369@oracle.com>
References: <20160301174233.GO16369@oracle.com>
 <CAM_iQpU8WNCi3GEW0isLsMDWOwzFVkHmDmnqzueLOf7K6P=mAg@mail.gmail.com>
 <20160301182102.GR16369@oracle.com>
 <CAM_iQpXwd9fQqEh1o56fVqoxUYC5ctY9wqjkAA7UeGru+T8bjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	john fastabend <john.fastabend@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:37898 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbcCASl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 13:41:26 -0500
Content-Disposition: inline
In-Reply-To: <CAM_iQpXwd9fQqEh1o56fVqoxUYC5ctY9wqjkAA7UeGru+T8bjw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/01/16 10:23), Cong Wang wrote:
> > The compiler error is for fields within the union which lacks
> > both a tag and a union-name.  So I'm not sure how the above will
> > help.
> >
> 
> Come on.. we have plenty of such anonymous unions in skbuff.h...

I realize that, even netdevice.h itself has other instances.
Thus I dont understand why this one generated a compiler error 
for me.  Thus I was wondering why others had not run into this
and not suggesting it should be patched.

However, changing the way we set up type etc. doesnt seem relevant
to what the compiler is flagging.

--Sowmini
