From: Dave Morgan <davemorgan353@btinternet.com>
Subject: Re: [Bugme-new] [Bug 16503] New: Upgrade to 2.6.34.2 breaks
 ethernet network
Date: Wed, 4 Aug 2010 19:59:46 +0100
Message-ID: <20100804185946.GA5002@Archer>
References: <bug-16503-10286@https.bugzilla.kernel.org/>
 <20100803132740.946cf78a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Gary Zambrano <zambrano@broadcom.com>, stable@kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp823.mail.ird.yahoo.com ([217.146.188.233]:37275 "HELO
	smtp823.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933546Ab0HDTG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 15:06:28 -0400
Content-Disposition: inline
In-Reply-To: <20100803132740.946cf78a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/08/10 at 01:27pm, Andrew Morton wrote:
>
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Tue, 3 Aug 2010 20:14:34 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>
> > https://bugzilla.kernel.org/show_bug.cgi?id=16503
> >
> >            Summary: Upgrade to 2.6.34.2 breaks ethernet network
> >            Product: Networking
> >            Version: 2.5
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: acme@ghostprotocols.net
> >         ReportedBy: davemorgan353@btinternet.com
> >         Regression: No
> >
> >
> > Using Arch Linux with fully up-to-date system.
> >
> > Upgrading kernel from 2.6.34.1 to 2.6.34.2 breaks my ethernet connection.  I
> > get dhcp timeouts but no errors in the logs regarding the kernel or the card.
> >
> > Dell Inspiron 1720.
> >
> > 03:00.0 Ethernet controller: Broadcom Corporation BCM4401-B0 100Base-TX (rev
> > 02)
> >
> > Downgrading the kernel fixes the issue.
> >
>
> There are no changes to b44.c in patch-2.6.34.2.  Perhaps you could
> generate the dmesg logs for 2.6.34.1 and 2.6.34.2 and run `diff -u'
> against them, see if anything interesting pops out?
>

There's nothing obvious to me in the logs.

However, it looks like it may be related to the ssb issues affecting
b43.

https://bugzilla.kernel.org/attachment.cgi?id=27335&action=diff

There are reports of my card working with 2.6.35 so I will upgrade to
that version.

--
Dave.
