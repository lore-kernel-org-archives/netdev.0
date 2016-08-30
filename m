From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH] iproute: disallow ip rule del without parameters
Date: Tue, 30 Aug 2016 13:51:56 +0200
Message-ID: <20160830115156.GB17087@unicorn.suse.cz>
References: <20160824204252.2melotzdx6ftzgaq@ppc.Dlink>
 <20160829105325.40230e41@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Andrey Jr. Melnikov" <temnota.am@gmail.com>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:32834 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758331AbcH3LwC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 07:52:02 -0400
Content-Disposition: inline
In-Reply-To: <20160829105325.40230e41@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 29, 2016 at 10:53:25AM -0700, Stephen Hemminger wrote:
> On Wed, 24 Aug 2016 23:43:00 +0300
> "Andrey Jr. Melnikov" <temnota.am@gmail.com> wrote:
> 
> > Disallow run `ip rule del` without any parameter to avoid delete any first
> > rule from table.
...
> Actually ip rule delete without arguments deletes all rules.
> Which could be a bug or feature depending on the user.
> I can imagine somebody is doing something like deleting all rules
> and putting in new ones for PBR.

We have "ip rule flush" for that, don't we?

Michal Kubecek
