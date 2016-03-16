From: Dexuan Cui <decui@microsoft.com>
Subject: RE: When will net-next merge with linux-next?
Date: Wed, 16 Mar 2016 02:58:40 +0000
Message-ID: <BLUPR03MB1410C679835D15348F498F46BF8A0@BLUPR03MB1410.namprd03.prod.outlook.com>
References: <BLUPR03MB14106249C57CCF66717CC860BF880@BLUPR03MB1410.namprd03.prod.outlook.com>
 <20160314162139.GA2925@kroah.com>
 <BLUPR03MB141045D7EED478CB0A086CA1BF890@BLUPR03MB1410.namprd03.prod.outlook.com>
 <20160315150534.GB12990@kroah.com>
 <BLUPR03MB14104FD16924FB8327BD9AA8BF8A0@BLUPR03MB1410.namprd03.prod.outlook.com>
 <20160316024058.GA29922@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0146.outbound.protection.outlook.com ([157.56.111.146]:29376
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S934099AbcCPDNw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 23:13:52 -0400
In-Reply-To: <20160316024058.GA29922@kroah.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: gregkh@linuxfoundation.org [mailto:gregkh@linuxfoundation.org]
> Sent: Wednesday, March 16, 2016 10:41
> To: Dexuan Cui <decui@microsoft.com>
> Cc: David Miller <davem@davemloft.net>; netdev@vger.kernel.org; KY
> Srinivasan <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>
> Subject: Re: When will net-next merge with linux-next?
> 
> On Wed, Mar 16, 2016 at 01:58:50AM +0000, Dexuan Cui wrote:
> > > From: gregkh@linuxfoundation.org [mailto:gregkh@linuxfoundation.org]
> > > Sent: Tuesday, March 15, 2016 23:06
> > > To: Dexuan Cui <decui@microsoft.com>
> > > Cc: David Miller <davem@davemloft.net>; netdev@vger.kernel.org; KY
> > > Srinivasan <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>
> > > Subject: Re: When will net-next merge with linux-next?
> > >
> > > On Tue, Mar 15, 2016 at 11:11:34AM +0000, Dexuan Cui wrote:
> > > > I'm wondering whether (and when) step 2 will happen in the next 2 weeks,
> > > > that is, before the tag 4.6-rc1 is made.
> > > > If not, I guess I'll miss 4.6?
> > >
> > > You missed 4.6 as your patch was not in any of our trees a few days
> > > before 4.5 was released, sorry.
> > >
> > > greg k-h
> > Hi Greg,
> > Thanks for the reply!
> >
> > My patch has to go in net-next first, but even today's mainline and net-next
> > haven't had the supporting patches in the VMBus driver, so I can't post my
> > patch to net-next even today  -- it seems it's doomed to need 2 major
> > release cycles to push a feature that makes changes to 2 subsystems? :-(
> 
> Usually, yes, unless you talk to us ahead of time so we can coordinate,
> or have one of the patches go through a different tree (i.e. all in one
> tree.).

Greg, Thanks for your patient explanation!
I thought the patch (AF_HYPERV) must go through net-next. 
 
> Just wait until 4.6-rc1 is out and all will be fine.
> 
> greg k-h

BTW, I saw this in Documentation/development-process/2.Process:

"As a general rule, if you miss the merge window for a given feature, the
best thing to do is to wait for the next development cycle.  (An occasional
exception is made for drivers for previously-unsupported hardware; if they
touch no in-tree code, they cannot cause regressions and should be safe to
add at any time)"

I hope David could make an exception for the AF_HYPERV patch, since it
is a new driver, touching no in-tree code and unlikely to cause regressions. :-)

And actually the new driver won't be automatically loaded -- a user must
manually load it before the feature can be used.

Thanks,
-- Dexuan
