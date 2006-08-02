From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [RFC 1/3] secid reconciliation on inbound
Date: Wed, 2 Aug 2006 08:57:55 -0400
Message-ID: <36282A1733C57546BE392885C061859201466C0E@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	Chad Hanson <chanson@TrustedCS.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:12122 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1750908AbWHBM6M
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 08:58:12 -0400
To: James Morris <jmorris@namei.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Tue, 1 Aug 2006, James Morris wrote:
> 
> > On Tue, 1 Aug 2006, Venkat Yekkirala wrote:
> > 
> > > +#define PACKET__COME_THRU                         0x00000008UL
> > > +#define PACKET__GO_THRU                           0x00000010UL
> > 
> > These names seem awkward, and do we really need a separate 
> perm for each 
> > direction?
> 
> Ok, I see we need separate permissions.  The naming, still...

You are probably seeing something I haven't :), because I did
consider using just one perm such as flow_thru for both directions
but then thought separate perms would make things easier to understand.

As for naming, how about "enter" and "leave"? Or "flow_in" and "flow_out".
Any other suggestions out there?
