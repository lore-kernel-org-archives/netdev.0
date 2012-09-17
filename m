From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] ncm: allow for NULL terminations
Date: Mon, 17 Sep 2012 17:31:49 +0100
Message-ID: <20120917173149.4730024c@pyramind.ukuu.org.uk>
References: <20120917105853.30298.29234.stgit@localhost.localdomain>
	<1347896724.2685.2.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:33449 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278Ab2IQQ1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 12:27:01 -0400
In-Reply-To: <1347896724.2685.2.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Sep 2012 16:45:24 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Mon, 2012-09-17 at 11:58 +0100, Alan Cox wrote:
> > From: Alan Cox <alan@linux.intel.com>
> > 
> > The strings are passed to snprintf so must be null terminated. It seems the
> > copy length is incorrectly set.
> 
> Please use strlcpy() instead.  (I thought someone had already gone round
> the get_drvinfo implementations and fixed them to do that, actually.)

There are still plenty of them. I'm just noting they are one out. I'm
doing a first pass over a whole pile of stuff so if you'd prefer it in a
different form treat it as a note to the maintainer than their code is
buggy as I probably won't be back round to it for a couple of months
judging by the size of the audit pile I'm working down.

Alan
