From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [patch 2/8] forcedeth: fix MAC address detection on network card (regression in 2.6.23)
Date: Thu, 22 Nov 2007 02:34:35 +0100
Message-ID: <9a8748490711211734p2e28cfb2q666ef719c9289201@mail.gmail.com>
References: <200711212302.lALN2sF8013655@imap1.linux-foundation.org>
	 <F72FA20C31DD4F4C997B91C5B3690A091A9857@hqemmail07.nvidia.com>
	 <20071121154723.34c5f647.akpm@linux-foundation.org>
	 <200711211850.36744.michael.pyne@kdemail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"Ayaz Abdulla" <AAbdulla@nvidia.com>, jeff@garzik.org,
	netdev@vger.kernel.org, stable@kernel.org
To: "Michael Pyne" <michael.pyne@kdemail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:29055 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752375AbXKVBeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 20:34:36 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2988726wah
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2007 17:34:35 -0800 (PST)
In-Reply-To: <200711211850.36744.michael.pyne@kdemail.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/11/2007, Michael Pyne <michael.pyne@kdemail.net> wrote:
> On Wednesday 21 November 2007, Andrew Morton wrote:
> > On Wed, 21 Nov 2007 15:34:52 -0800
> >
> > "Ayaz Abdulla" <AAbdulla@nvidia.com> wrote:
> > > The solution is to get the OEM to update their BIOS (instead of
> > > integrating this patch) since the MCP61 specs indicate that the MAC
> > > Address should be in correct order from BIOS.
> > >
> > > By changing the feature DEV_HAS_CORRECT_MACADDR to all MCP61 boards, it
> > > could cause it to break on other OEM systems who have implemented it
> > > correctly.
> >
> > Getting an OEM to fix their BIOS isn't always a simple thing...
> >
> > Perhaps Michael's change should be enabled by a module parameter for
> > those who happen to have the busted BIOS?
>
> I have contacted the motherboard vendor about this a couple of weeks ago per
> Ayaz's request and have received no response.  I've also upgraded to the
> latest firmware for this motherboard and the bug remains.
>
> I think it would be ideal if there were a way to detect broken MCP61's (i.e.
> those with a Gigabyte MAC ID instead of the nVidia one) and only reverse the
> MAC address then.  A module parameter would also work but then I'd need to
> remember to apply it. :)
>

Hmm, MAC address makeups are not my strong point, but are the no rules
describing the various parts of the address that could perhaps be used
to infer programatically if the address seems to be reversed or not,
and then use that detection logic for all boards that are known to
potentially have the issue?
A module parameter that overrules the automatic detection (for when it
gets it wrong) would probably also be a good idea.


-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
