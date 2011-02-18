From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v6 0/9] net: Unified offload configuration
Date: Fri, 18 Feb 2011 20:27:51 +0100
Message-ID: <20110218192751.GA24031@rere.qmqm.pl>
References: <cover.1297824704.git.mirq-linux@rere.qmqm.pl> <20110217.145611.229745070.davem@davemloft.net> <20110218142238.GA18099@rere.qmqm.pl> <1298039371.2211.9.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:56376 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757706Ab1BRT1x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Feb 2011 14:27:53 -0500
Content-Disposition: inline
In-Reply-To: <1298039371.2211.9.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 18, 2011 at 02:29:31PM +0000, Ben Hutchings wrote:
> On Fri, 2011-02-18 at 15:22 +0100, Micha=B3 Miros=B3aw wrote:
> > On Thu, Feb 17, 2011 at 02:56:11PM -0800, David Miller wrote:
> [...]
> > > Please get rid of that annoying message spit out by netif_feature=
s_change(),
> > > it's just spam.  If we want notifications for stuff like this, us=
e a
> > > non-unicast netlink message so those who want to hear it can do s=
o.
> > You mean netdev_update_features() "Features changed" message? Is it=
 ok
> > to just demote it to DEBUG level or you want to remove it altogethe=
r?
> > What about netdev_fix_features() messages?
> I think you need to emit these messages at 'error' severity when fixi=
ng
> up features for a newly-added device, but at 'debug' later on.

Why the difference? Those messages on startup matter mostly to develope=
rs
and later mostly to users. Anyway, the conditions in netdev_fix_feature=
s()
are all constant (dependent only on net core implementation).

Best Regards,
Micha=B3 Miros=B3aw
