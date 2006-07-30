From: David Miller <davem@davemloft.net>
Subject: Re: Subsystem/prefix in patch submission format
Date: Sun, 30 Jul 2006 15:59:56 -0700 (PDT)
Message-ID: <20060730.155956.106769160.davem@davemloft.net>
References: <Pine.LNX.4.58.0607301342150.19037@kivilampi-30.cs.helsinki.fi>
	<20060730.152846.42906358.davem@davemloft.net>
	<20060730224543.GA9506@mars.ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:24981
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964782AbWG3W7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 18:59:46 -0400
To: sam@ravnborg.org
In-Reply-To: <20060730224543.GA9506@mars.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sam Ravnborg <sam@ravnborg.org>
Date: Mon, 31 Jul 2006 00:45:43 +0200

> >From a pure eye-candy perspective it would be nice to use same format
> all over.
> >From Documentation/SubmittingPatches:
> ------------------
> 12) The canonical patch format
> 
> The canonical patch subject line is:
> 
>     Subject: [PATCH 001/123] subsystem: summary phrase
> --------------

The patch format specifies things that make no sense
when the changes gets into the tree.  Especially the
sequence numbers, which are implied by the changes
placement in the relative changeset history.

We are getting into the realm of personal taste, and I
fail to see any benefit from enforcing one subsystem to
adopt a different schema if what they're doing now provides
all the necessary information and works well for them.
