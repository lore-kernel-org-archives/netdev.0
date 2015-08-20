From: Premkumar Jonnala <pjonnala@broadcom.com>
Subject: RE: [PATCH] bridge: Enable configuration of ageing interval for
 bridges and switch devices.
Date: Thu, 20 Aug 2015 06:40:01 +0000
Message-ID: <77EF4405DD4BB54AACCE7DB593DF6A9A9E3114@SJEXCHMB14.corp.ad.broadcom.com>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9E1E8D@SJEXCHMB14.corp.ad.broadcom.com>
 <alpine.DEB.2.02.1508172358470.13562@rocker1.rocker.net>
 <77EF4405DD4BB54AACCE7DB593DF6A9A9E2BFE@SJEXCHMB14.corp.ad.broadcom.com>
 <CAE4R7bD-r1=xo2+HMKdPpf7A3Vd7SXYsxm=xC0oNANtuG+F4iw@mail.gmail.com>
 <91179B48C1F7014B86296413F181061E3D56B6E1@FMSMSX114.amr.corp.intel.com>
 <77EF4405DD4BB54AACCE7DB593DF6A9A9E3076@SJEXCHMB14.corp.ad.broadcom.com>
 <20150820063019.GA11515@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Wilson, Daniel G" <daniel.wilson@intel.com>,
	Scott Feldman <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:6326 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633AbbHTGkD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 02:40:03 -0400
In-Reply-To: <20150820063019.GA11515@unicorn.suse.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Michal Kubecek [mailto:mkubecek@suse.cz]
> Sent: Thursday, August 20, 2015 12:00 PM
> To: Premkumar Jonnala
> Cc: Wilson, Daniel G; Scott Feldman; netdev@vger.kernel.org
> Subject: Re: [PATCH] bridge: Enable configuration of ageing interval for bridges
> and switch devices.
> 
> On Thu, Aug 20, 2015 at 05:08:51AM +0000, Premkumar Jonnala wrote:
> > > From: Wilson, Daniel G [mailto:daniel.wilson@intel.com]
> > > >
> > > > Can you extend bridge command to allow setting/getting these bridge
> attrs?
> > > > Looks like you construct a RTM_NEWLINK IFLA_INFO_DATA msg.  No
> changes
> > > > needed to the kernel.
> > > >
> > > > bridge link set dev br0 ageing_time 1000
> > > >
> > > >  --or--
> > > >
> > > > ip link set dev br0 type bridge ageing_time 1000
> > >
> > > Being able to set these attributes via both bridge and ip would be great.
> > >
> > IMHO, we should choose only one command.  Otherwise, we'd have to
> > spend effort in trying to keep both the commands in sync.
> 
> As long as they are using the same netlink interface, I don't think it's
> a serious problem. After all, there will be also other tools (wicked,
> perhaps systemd-networkd) setting it directly via netlink rather than
> calling either ip or bridge.
> 
> > My vote would be for the bridge command - since the options/parameters
> > are related to bridges.  If there is no objection, I'll move all the
> > bridge options from 'ip link' command to 'bridge' command.
> 
> This would break existing scripts using ip to set the parameter. Is the
> possibility to use any of the two really that bad?

There was another email on this thread where Scott indicated existence of other commands
where both ip and bridge are available, and they are for the same function.

I will keep both the ip and bridge commands, and try to share the underlying code as much as possible.

-Prem

> 
>                                                          Michal Kubecek
