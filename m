From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: NETLINK_URELEASE non-bound socket problem (was: [PATCH] Fix
 local DoS in cfg80211 subsystem)
Date: Wed, 06 Apr 2016 11:34:41 +0200
Message-ID: <1459935281.17504.69.camel@sipsolutions.net>
References: <CAFSVvRfjZszSfovXZ0piPqOgVKH=10sG7pvnvkoWJChL38ifqQ@mail.gmail.com>
	 <1459850188.18188.38.camel@sipsolutions.net>
	 <CAFSVvRcMQx1Vjv=Qwyb525Qq5DzBBD6c=n=-i+pWFFVqHRyAxQ@mail.gmail.com>
	 (sfid-20160406_102025_380946_ED0DACD9)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	samuel <samuel@sortiz.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>
To: Dmitrijs Ivanovs <dmitrijs.ivanovs@ubnt.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:36254 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932159AbcDFJer (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 05:34:47 -0400
In-Reply-To: <CAFSVvRcMQx1Vjv=Qwyb525Qq5DzBBD6c=n=-i+pWFFVqHRyAxQ@mail.gmail.com> (sfid-20160406_102025_380946_ED0DACD9)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-06 at 11:20 +0300, Dmitrijs Ivanovs wrote:
> Hi Johannes!
> 
> I will prepare patch which does not send NETLINK_URELEASE for unbound
> sockets as you suggest. But I think protocol check in nl80211 is
> still needed because port_id is unique per-protocol.
> 

Yes, good point. Can you please send that as a separate patch? That one
should have a

Fixes: 026331c4d9b5 ("cfg80211/mac80211: allow registering for and sending action frames")

tag. I'll apply this one right away, but the other one should probably
go through Dave's tree.

Thanks,
johannes
