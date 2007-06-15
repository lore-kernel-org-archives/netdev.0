From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.22-rc4 hibernate disables skge wol
Date: Sat, 16 Jun 2007 00:04:30 +0200
Message-ID: <200706160004.30932.rjw@sisk.pl>
References: <467309B8.2060001@dgreaves.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-pm <linux-pm@lists.osdl.org>
To: David Greaves <david@dgreaves.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:57206 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758037AbXFOV5x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2007 17:57:53 -0400
In-Reply-To: <467309B8.2060001@dgreaves.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, 15 June 2007 23:50, David Greaves wrote:
> I've started a new thread here since the old one got somewhat hijacked.
> 
> Rafael J. Wysocki wrote:
>  > On Friday, 1 June 2007 23:23, David Greaves wrote:
>  >> Not a regression though, it does it in 2.6.21
>  >>
>  >> If I cause the system to save state to disk then whilst off it no longer
>  >> responds to g-wol.
>  >
>  > Can you please try with the hibernation and suspend patch series from
>  >
>  > http://www.sisk.pl/kernel/hibernation_and_suspend/2.6.22-rc3/patches/
>  >
>  > applied?
>  >
>  > Greetings,
>  > Rafael
>  >
>  >
> Now, IIRC, some time ago you asked me to try some patches :)
> 
> So I applied them (and Tejun's fixes as per the old thread) to rc4 (which seems 
> to include a couple already).
> 
> Hibernate/resume works but although WOL works on an init 0, it doesn't work on a 
> hibernated system :(

Well, I have one idea, but I'd like the recent paches currently in -mm to
settle down before trying it. ;-)

In the meantime, you may want to open a bugzilla entry related to this issue
(please add my address to the CC list if you do that).

Greetings,
Rafael


-- 
"Premature optimization is the root of all evil." - Donald Knuth
