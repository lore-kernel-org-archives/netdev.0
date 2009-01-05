From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] dccp: Clean up ccid.c after integration of CCID
 plugins
Date: Sun, 04 Jan 2009 21:46:00 -0800 (PST)
Message-ID: <20090104.214600.119496484.davem@davemloft.net>
References: <1230967849-9456-1-git-send-email-gerrit@erg.abdn.ac.uk>
	<1230967849-9456-2-git-send-email-gerrit@erg.abdn.ac.uk>
	<1230967849-9456-3-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42410
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751136AbZAEFp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 00:45:56 -0500
In-Reply-To: <1230967849-9456-3-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat,  3 Jan 2009 08:30:48 +0100

> This patch cleans up after integrating the CCID modules and, in addition,
> 
>  * moves the if/else cases from ccid_delete() into ccid_hc_{tx,rx}_delete();
>  * removes the 'gfp' argument to ccid_new() - since it is always gfp_any().
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied.
