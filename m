From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 2/5] dccp: Deprecate old setsockopt framework
Date: Mon, 17 Nov 2008 16:31:55 +0100
Message-ID: <20081117153155.GA3446@gerrit.erg.abdn.ac.uk>
References: <1226751079-15019-1-git-send-email-gerrit@erg.abdn.ac.uk> <1226751079-15019-2-git-send-email-gerrit@erg.abdn.ac.uk> <1226751079-15019-3-git-send-email-gerrit@erg.abdn.ac.uk> <20081116.225310.261827389.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:32794 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750919AbYKQPcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 10:32:04 -0500
Content-Disposition: inline
In-Reply-To: <20081116.225310.261827389.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > This patch removes the old setsockopt interface and replaces it with two new
| > functions to register NN/SP values for feature negotiation. 
<snip>
| But you have to understand that this is something you should think
| about never doing again.  User interfaces are never "oops sorry, we
| misdesigned that, we'll just take it away and emit some warning,
| fix your app"  Once it's out there, you gotta support it forever.
| 

I hope that the present solution of replacing is sufficient since there was
at least one crash reported with the old interface, on
http://www.spinics.net/lists/dccp/msg03371.html

Later within the patch set (not in the current submission) there is also a 
setsockopt warning that the old interface is no longer valid (in the patch
"dccp: Deprecate old setsockopt framework" on http://eden-feed.erg.abdn.ac.uk).

With regard to interface changes, it would be best/easier to keep them within
one release. I am not up-to-date how long net-next-2.6 will remain open,
but if you are pushing it out soon, it would be best not to push out the old
and the new interface in parallel.

I am otherwise happy to resubmit the reviewed patches again later, as
already done after the last merge window.

With regard to compilation there are no concerns, patches are all tested to
compile standalone.

Please let me know how you would like to proceed.

Gerrit
