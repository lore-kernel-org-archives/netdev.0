From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 PATCH 1/2] Add netdev port-profile support (take III, was iovnl)
Date: Wed, 28 Apr 2010 21:37:28 +0200
Message-ID: <201004282137.28492.arnd@arndb.de>
References: <C7FDD272.2C86D%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com,
	Jens Osterkamp <Jens.Osterkamp@gmx.de>
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:56427 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055Ab0D1Thr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:37:47 -0400
In-Reply-To: <C7FDD272.2C86D%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 28 April 2010, Scott Feldman wrote:
> On 4/28/10 6:13 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:
> 
> > What I could imagine to unify this is something like
> > 
> >    ip port_profile set DEVICE [ { pre_associate | pre_associate_rr } ]
> >                               { name PORT-PROFILE | vsi MGR:VTID:VER }
> >                                     mac LLADDR
> >    [ vlan VID ]
> >                                     [ host_uuid HOST_UUID ]
> >                                     [ client_uuid CLIENT_UUID ]
> >                                     [ client_name CLIENT_NAME ]
> >    ip port_profile del DEVICE [ mac LLADDR [ vlan VID ] ]
> >    ip port_profile show DEVICE
> 
> Arnd, can someone test this with VDP today?  I don't have access to that
> equipment so it's difficult for me to fully test the unified patch.  I can
> test the previous patch with enic easily because I have access to production
> systems.  I'd like to make sure someone can test this with VDP before I
> respin the patch one more time.

Sorry, but I don't have access to production hardware at this time. Jens wants to
implement both sides so we can test this in simulation mode, but it's not done
yet.

	Arnd
