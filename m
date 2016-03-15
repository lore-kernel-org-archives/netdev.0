From: Dexuan Cui <decui@microsoft.com>
Subject: RE: When will net-next merge with linux-next?
Date: Tue, 15 Mar 2016 11:11:34 +0000
Message-ID: <BLUPR03MB141045D7EED478CB0A086CA1BF890@BLUPR03MB1410.namprd03.prod.outlook.com>
References: <BLUPR03MB14106249C57CCF66717CC860BF880@BLUPR03MB1410.namprd03.prod.outlook.com>
 <20160314162139.GA2925@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0144.outbound.protection.outlook.com ([65.55.169.144]:61312
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755265AbcCOLMJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 07:12:09 -0400
In-Reply-To: <20160314162139.GA2925@kroah.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: gregkh@linuxfoundation.org [mailto:gregkh@linuxfoundation.org]
> Sent: Tuesday, March 15, 2016 0:22
> To: Dexuan Cui <decui@microsoft.com>
> Cc: David Miller <davem@davemloft.net>; netdev@vger.kernel.org; KY
> Srinivasan <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>
> Subject: Re: When will net-next merge with linux-next?
> 
> On Mon, Mar 14, 2016 at 06:09:41AM +0000, Dexuan Cui wrote:
> > Hi David,
> > I have a pending patch of the hv_sock driver, which should go into the
> > kernel through the net-next tree:
> >
> https://lkml.org/lkml/2016/2/14/7
>
> > The VMBus side's supporting patches of hv_sock have been in Greg's tree
> > and linux-next for more than 1 month, but they haven't been in net-next
> > yet, I suppose this is because of the releasing of 4.5.
> >
> > Now 4.5 is released. Will you merge with Greg's tree or linux-next?
> 
> linux-next is a merge of all of the maintainer's trees, and it is
> rebased every day, it's impossible to merge that back into a maintainers
> tree, sorry.

Greg, thanks for the reply!
 
> > I read netdev-FAQ.txt, but still don't have a clear idea about how things
> > work in my case.
> 
> Try reading Documentation/development-process/ please.  Things will get
> merged together into Linus's tree over the next 2 weeks as we ask him to
> pull our trees.
> 
> greg k-h

I read the development-process documents. 
Since 4.5 was released and Linus's merge window is open for 4.6, I guess
what will happen next is:
1. Linus will pull from char-misc.git and net-netx.git;
2. David will merge with Linus's mainline tree;
3. I can post my patch to net-next.git then.

I'm wondering whether (and when) step 2 will happen in the next 2 weeks,
that is, before the tag 4.6-rc1 is made.
If not, I guess I'll miss 4.6?

Thanks,
-- Dexuan
