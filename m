From: James Morris <jmorris@namei.org>
Subject: Re: Refactor Netlink connector?
Date: Wed, 31 May 2006 11:42:45 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605311141320.4964@d.namei>
References: <Pine.LNX.4.64.0605261552570.4856@d.namei>  <20060527134629.GA16306@2ka.mipt.ru>
  <Pine.LNX.4.64.0605271223390.12872@d.namei>  <Pine.LNX.4.64.0605271303050.13104@d.namei>
  <20060531030046.GC7844@postel.suug.ch> <1149078055.5462.55.camel@jzny2>
 <20060531130649.GD7844@postel.suug.ch> <1149081752.5462.98.camel@jzny2>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Thomas Graf <tgraf@suug.ch>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sea5.speakeasy.net ([69.17.117.6]:54160 "EHLO
	mail4.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S965066AbWEaPms (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 11:42:48 -0400
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1149081752.5462.98.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 May 2006, jamal wrote:

> To also answer your other email:
> Look at  security/selinux/nlmsgtab.c for example for NETLINK_ROUTE
> and compare with NETLINK_GENERIC to see the hole. I was suggesting if
> we started by just adding checks for NETLINK_GENERIC first in those
> tables (currently lacking), that would be a good start.

They're currently mediated as a generic netlink socket type at a higher 
level: they're not unmediated, just not fine grained enough to know what 
kind of message is being sent.


-- 
James Morris
<jmorris@namei.org>
