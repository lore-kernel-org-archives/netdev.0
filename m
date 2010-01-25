From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Regression: Wake on LAN doesn't work in sky2 with
 2.6.33-rc4-git2
Date: Sun, 24 Jan 2010 20:42:23 -0800
Message-ID: <20100124204223.3439e297@nehalam>
References: <20100115091053.GA5477@mac.home>
	<20100119105105.184c3f01@nehalam>
	<20100119193745.GA5797@x61.home>
	<201001242135.29309.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tino Keitel <tino.keitel@gmx.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35074 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751466Ab0AYEmp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jan 2010 23:42:45 -0500
In-Reply-To: <201001242135.29309.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 24 Jan 2010 21:35:29 +0100
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> On Tuesday 19 January 2010, Tino Keitel wrote:
> > On Tue, Jan 19, 2010 at 10:51:05 -0800, Stephen Hemminger wrote:
> > > Is this better worse or the same? It make sure that some
> > > registers are set on resume that might matter.
> > 
> > I see not difference.
> 
> Hmm.  Perhaps it's better to revert commit 166a0fd4c788ec7f10ca8194ec6d526afa12db75
> for now, so that 2.6.33 works on the Tino's machine, and figure out why it
> broke the WoL before (eventually) re-applying it?
> 
> Rafael

Agreed

-- 
