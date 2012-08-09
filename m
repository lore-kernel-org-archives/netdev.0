From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [net-next] bonding: don't allow the master to become its slave
Date: Thu, 9 Aug 2012 16:39:06 -0300
Message-ID: <20120809163906.6dc0b6d4@obelix.rh>
References: <1344537049-11473-1-git-send-email-fbl@redhat.com>
	<1344539003.2593.7.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Leonardo Chiquitto <lchiquitto@suse.com>,
	Jiri Pirko <jpirko@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43922 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759409Ab2HITpN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 15:45:13 -0400
In-Reply-To: <1344539003.2593.7.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 9 Aug 2012 20:03:23 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Thu, 2012-08-09 at 15:30 -0300, Flavio Leitner wrote:
> > It doesn't make any sense to allow the master to become
> > its slave. That creates a loop of events causing a crash.
> 
> What if there are other intermediate devices, e.g. the slave is a VLAN
> sub-device of the bond?  And doesn't team also have this problem?
> 
> I think a more general check for such loops might be required.

Maybe patching netdev_set_master() to fail in the loop case is
the way to go.  That would work for bonding, team and bridge.

What you think?

fbl
