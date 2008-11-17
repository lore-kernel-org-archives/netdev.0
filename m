From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] dccp: Tidy up setsockopt calls
Date: Sun, 16 Nov 2008 22:57:05 -0800 (PST)
Message-ID: <20081116.225705.57687104.davem@davemloft.net>
References: <1226751079-15019-4-git-send-email-gerrit@erg.abdn.ac.uk>
	<1226751079-15019-5-git-send-email-gerrit@erg.abdn.ac.uk>
	<1226751079-15019-6-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48343
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751878AbYKQG5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 01:57:06 -0500
In-Reply-To: <1226751079-15019-6-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 15 Nov 2008 13:11:19 +0100

> This splits the setsockopt calls into two groups, depending on whether an
> integer argument (val) is required and whether routines being called do
> their own locking.
> 
> Some options (such as setting the CCID) use u8 rather than int, so that for
> these the test with regard to integer-sizeof can not be used.
> 
> The second switch-case statement now only has those statements which need
> locking and which make use of `val'.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> Reviewed-by: Eugene Teo <eugeneteo@kernel.sg>

Applied.
