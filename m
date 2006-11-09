From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Turn nfmark into generic mark
Date: Thu, 9 Nov 2006 13:45:48 +0100
Message-ID: <20061109124548.GA8693@postel.suug.ch>
References: <20061109113245.439512828@lsx.localdomain> <20061109123234.EC7FC1434F@rhn.tartu-labor>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:16593 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932816AbWKIMp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 07:45:28 -0500
To: Meelis Roos <mroos@linux.ee>
Content-Disposition: inline
In-Reply-To: <20061109123234.EC7FC1434F@rhn.tartu-labor>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Meelis Roos <mroos@linux.ee> 2006-11-09 14:32
> Another thought: sometimes a single mark makes rulesets inconvenient.
> What about several independent marks on a packet?

The mark is already a bitfield, you may dividide it into separate
marks with the exception of routes which do not yet support a
mask.
