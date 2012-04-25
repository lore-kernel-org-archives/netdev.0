From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: My e1000e GBE card is eating all port 623 pks
Date: Wed, 25 Apr 2012 11:06:58 +0200
Message-ID: <OF497D4E52.CC9EA3C0-ONC12579EB.0031DCB3-C12579EB.003213E4@transmode.se>
References: <OF8F83D7F0.387F6CCE-ONC12579E7.0049B885-C12579E7.004A4356@transmode.se> <20120424145128.000070a8@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:57949 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756456Ab2DYJHC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 05:07:02 -0400
In-Reply-To: <20120424145128.000070a8@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Brandeburg <jesse.brandeburg@intel.com> wrote on 2012/04/24 23:51:28:
>
> On Sat, 21 Apr 2012 15:31:09 +0200
> Joakim Tjernlund <joakim.tjernlund@transmode.se> wrote:
>
> > Looks like port 623 is some mgmt protocol and our e1000e boards are eating these
> > pkgs and this trips NIS, finger and yptest hangs for a long time before timing out and
> > moving on.
> >
> > Is there a way to tell the network stack not to eat port 623 pkgs or
> > have NIS not to use port 623?
>
> I think you might be looking for something like portreserve
> (see man portreserve)

Seen portreserve on the web(gentoo does not have it) but it seems like a workaround.
Should not eating port 623 be something one should turn on? Now it is default on
and I cannot find a way to turn it off.

 Jocke
