From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] XFRM: assorted IPsec fixups
Date: Fri, 7 Dec 2007 15:45:41 -0500
Message-ID: <200712071545.45411.paul.moore@hp.com>
References: <20071207171116.18151.42328.stgit@flek.americas.hpqcorp.net> <1197059769.3183.16.camel@dhcp231-215.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
	selinux@tycho.nsa.gov
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:49073 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313AbXLGUp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 15:45:57 -0500
In-Reply-To: <1197059769.3183.16.camel@dhcp231-215.rdu.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 07 December 2007 3:36:08 pm Eric Paris wrote:
> On Fri, 2007-12-07 at 12:11 -0500, Paul Moore wrote:
> > This patch fixes a number of small but potentially troublesome things in
> > the XFRM/IPsec code:
> >
> >  * Use the 'audit_enabled' variable already in include/linux/audit.h
> >    Removed the need for extern declarations local to each XFRM audit
> > fuction

{snip}

> although it does make me wonder why audit_log_start doesn't just check
> audit_enabled itself....

/me shrugs ... I have no idea, I've just always followed the lead of what was 
already written, but now that you mention it - it doesn't make much sense.  I 
suppose at some point we can go through and change all the 'audit_enabled' 
users, but I wonder if there is some point (?performance?) to having the 
callers check?

-- 
paul moore
linux security @ hp
