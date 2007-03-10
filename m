From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: 2.6.19/2.6.20 BUG in inet_rtm_newaddr()/__inet_insert_ifa()
Date: Sat, 10 Mar 2007 14:55:39 +0100
Message-ID: <20070310135539.GB30620@janus>
References: <20070309103333.GA17232@janus> <20070309123016.GA4736@2ka.mipt.ru> <20070309182236.GA21587@janus> <20070310131917.GA25794@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:41598 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933282AbXCJNzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2007 08:55:41 -0500
Content-Disposition: inline
In-Reply-To: <20070310131917.GA25794@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 10, 2007 at 04:19:17PM +0300, Evgeniy Polyakov wrote:
> On Fri, Mar 09, 2007 at 07:22:36PM +0100, Frank van Maarseveen (frankvm@frankvm.com) wrote:
> > Ok that worked.. not as I expected. I don't understand the EINVAL and
> > "ip addr" shows no broadcast address for eth0 when a classless address is
> > added as the primary (and only) address like in the above example. That's
> > why I tried to set it manually in the second "ip" command.
> 
> Because you might want not 
> 
> ip addr add 172.18.12.99/21 dev dummy0
> ip addr add broadcast 172.18.15.255 dev dummy0
> 
> but 
> 
> ip addr add 172.18.12.99/21 broadcast 172.18.15.255 dev dummy0
> 
> Magic of local/global adresses is hidden here.

thanks!

-- 
Frank
