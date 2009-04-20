From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH net-next] myri10ge: allow per-board firmware overriding
Date: Mon, 20 Apr 2009 13:53:42 +0200
Message-ID: <20090420135342.417f3ebd@dhcp-lab-109.englab.brq.redhat.com>
References: <49E7239B.4000309@myri.com>
	<20090417095038.49b745bf@dhcp-lab-109.englab.brq.redhat.com>
	<49EA1DAC.1000602@myri.com>
	<1240102617.5342.6.camel@obelisk.thedillows.org>
	<1240108599.5342.11.camel@obelisk.thedillows.org>
	<20090420114041.37c7fa7b@dhcp-lab-109.englab.brq.redhat.com>
	<49EC4683.3060605@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Dillow <dave@thedillows.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48580 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755088AbZDTL75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 07:59:57 -0400
In-Reply-To: <49EC4683.3060605@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Apr 2009 11:55:15 +0200
Brice Goglin <brice@myri.com> wrote:

> Stanislaw Gruszka wrote:
> > Providing module_param_id would address this issues, but I have some concerns
> > before doing it:
> >
> > - device have to access ID (like serial no) before initialization (at least
> >   before driver will need parameter)
> > - why nobody already done it - perhaps such thing would be totally useless
> >   
> 
> Per-nic module parameters are used in some Intel NIC drivers but it's
> not considered a very good solution in the general case:
>
> http://kerneltrap.org/index.php?q=mailarchive/linux-netdev/2008/10/24/3801824/thread
> 
> But again, when talking about changing the NIC firmware, ethtool and
> friends are not that easy.

I agree that device parameters, which are not needed during initialization
or can be changed at runtime shall not be module parameters. I agree also
that some parameters are needed during startup when driver loads and are
driver specific. For these modules parameters shall be used. Firmware is one
example, I think we have others.

Cheers
Stanislaw
