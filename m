From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH RFC] Per route TCP options
Date: Tue, 20 Oct 2009 21:53:24 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0910202151160.22058@melkinkari.cs.Helsinki.FI>
References: <1256052161-14156-1-git-send-email-gilad@codefidence.com>
 <4ADDDAFB.5040600@gmail.com> <4ADDE132.3010408@codefidence.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243445-1356913944-1256064804=:22058"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>, ori@comsleep.com
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55737 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbZJTSxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 14:53:21 -0400
In-Reply-To: <4ADDE132.3010408@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243445-1356913944-1256064804=:22058
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Tue, 20 Oct 2009, Gilad Ben-Yossef wrote:

> Eric Dumazet wrote:
> 
> > Gilad Ben-Yossef a écrit :
> >   
> > > Turn the global sysctls allowing disabling of TCP SACK, DSCAK,
> > > time stamp and window scale into per route entry feature options,
> > > laying the ground to future removal of the relevant global sysctls.
> > >
> > > ...
> > Interesting... But you should give numbers to your patches so that we know
> > their order
> >   
> Will do.
> > You could also do the ECN part for consistency (ie RTAX_FEATURE_ECN ->
> > RTAX_FEATURE_NO_ECN)
> >   
> That and  sysctl_tcp_mtu_probing are on my todo list, assuming the general
> direction is accepted, of course.
> 
> Specifically, I couldn't understand why sysctl_tcp_ecn is documented to be a
> boolean value, but is initialized to 2 and queried with if (sysctl_tcp_ecn ==
> 1) so I decided to let it be until I figure it out... ;-)

Ah, I didn't notice that "- BOOLEAN" there so I modified only the 
description (some blindness to caps perhaps :-)), did you perhaps read
it fully?

-- 
 i.
---696243445-1356913944-1256064804=:22058--
