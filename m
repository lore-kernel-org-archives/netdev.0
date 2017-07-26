From: Phil Sutter <phil@nwl.cc>
Subject: Re: TC-pedit man page examples error
Date: Wed, 26 Jul 2017 10:43:38 +0200
Message-ID: <20170726084338.GH2235@orbyte.nwl.cc>
References: <CAEPezq43wKM1ivHAUu6pFoGqz9+nCJ1FT9xQV702S_BCQvropA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tyler Bautista <tylerbautista@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45291 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750813AbdGZInj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 04:43:39 -0400
Content-Disposition: inline
In-Reply-To: <CAEPezq43wKM1ivHAUu6pFoGqz9+nCJ1FT9xQV702S_BCQvropA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tyler,

On Tue, Jul 25, 2017 at 08:33:40AM -0700, Tyler Bautista wrote:
> To whom it may concern,
> I recently attempted to use simple tc action pedit commands on the man
> page and I ran into some errors. The following is some information
> about my version of iproute and my machine:
> ----------------------------
> the following is my iproute package information
> 
> Loaded plugins: fastestmirror, langpacks
> iproute-3.10.0-74.el7.x86_64

This mailing list is for upstream issues only. Can you reproduce the
problem with vanilla iproute2?

You are using RHEL7's iproute package, which has a number of known
issues in pedit action:

https://bugzilla.redhat.com/show_bug.cgi?id=1322406

These are planned to be resolved for RHEL7.5, not sure when it will land
in CentOS.

Cheers, Phil
