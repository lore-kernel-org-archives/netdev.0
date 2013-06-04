From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [RFC] vxlan: convert remote list to list_rcu
Date: Tue, 4 Jun 2013 12:18:08 +0300
Message-ID: <CAF1J0HMD-N64Qb2v3oLF7ovsHqhbh0w730t3cWn4uD6wdcLY7Q@mail.gmail.com>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1369821617-29098-3-git-send-email-mike.rapoport@ravellosystems.com>
	<20130530110948.GA10532@casper.infradead.org>
	<CAF1J0HP+Wu9HjEELDaXM2BMREMuKByWr_zz=PwHeNUt=EVbdvw@mail.gmail.com>
	<20130530113739.GB10532@casper.infradead.org>
	<20130531091740.70b3e077@nehalam.linuxnetplumber.net>
	<20130602102942.GA21706@zed>
	<20130603112616.3ad018e2@nehalam.linuxnetplumber.net>
	<OFE7269995.C8314337-ON85257B7F.006B4FC1-85257B7F.006F87F8@us.ibm.com>
	<20130603134512.46ce434f@nehalam.linuxnetplumber.net>
	<OFB0EFD290.FD0EF659-ON85257B7F.00733AF7-85257B7F.0077A32C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog110.obsmtp.com ([74.125.245.88]:43403 "HELO
	na3sys010aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752534Ab3FDJSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 05:18:09 -0400
Received: by mail-ob0-f172.google.com with SMTP id wo10so9050381obc.3
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 02:18:08 -0700 (PDT)
In-Reply-To: <OFB0EFD290.FD0EF659-ON85257B7F.00733AF7-85257B7F.0077A32C@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 4, 2013 at 12:46 AM, David Stevens <dlstevens@us.ibm.com> wrote:

> But i don't think any of this fdb code relates to the default
> destination directly, since the generic fdb code does not support
> default, or any other aggregate matching. VXLAN can define the
> netlink API for default destinations without affecting anything
> else, because it is already a per-device feature.
>
>                                                         +-DLS

The only relation is the 'struct vxlan_rdst' which I intended to use
for default destinations list. So, until there's a consensus about
remote destinations list in fdb, I cannot continue to work on multiple
default destinations.

--
Sincerely yours,
Mike.
