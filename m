From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.24-rc3: find complains about /proc/net
Date: Wed, 21 Nov 2007 02:01:15 +0100
Message-ID: <200711210201.16331.rjw@sisk.pl>
References: <4743026B.2020907@openvz.org> <20071120234505.GF23667@elte.hu> <20071120235114.0B85226F8BE@magilla.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Ulrich Drepper <drepper@redhat.com>,
	Guillaume Chazarain <guichaz@yahoo.fr>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Roland McGrath <roland@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:46636 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755855AbXKUAnW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 19:43:22 -0500
In-Reply-To: <20071120235114.0B85226F8BE@magilla.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, 21 of November 2007, Roland McGrath wrote:
> > can you see any danger to providing a /proc/self_task/ link? (or can you 
> > think of a better name/API/approach)
> 
> That is a poor name to choose given /proc/self/task exists as something
> else (just try writing a sentence comparing them and then read it aloud).
> Probably /proc/self/task/self is what makes the most sense structurally.
> I don't know if it matters to whatever use you are concerned with to have
> two more steps in the lookup.

Hm, /proc/this_thread maybe?

Rafael
