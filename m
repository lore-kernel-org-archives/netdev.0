From: David Miller <davem@davemloft.net>
Subject: Re: [DCCP]: Fix skb->cb conflicts with IP
Date: Fri, 11 Apr 2008 11:24:12 -0700 (PDT)
Message-ID: <20080411.112412.161949691.davem@davemloft.net>
References: <20080411135908.GA20937@gerrit.erg.abdn.ac.uk>
	<47FF6F9E.5050807@trash.net>
	<20080411140501.GR8192@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36698
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758913AbYDKSYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 14:24:11 -0400
In-Reply-To: <20080411140501.GR8192@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 11 Apr 2008 11:05:01 -0300

> Em Fri, Apr 11, 2008 at 04:03:10PM +0200, Patrick McHardy escreveu:
> > Gerrit Renker wrote:
> >>>>>     [DCCP]: Fix skb->cb conflicts with IP
> >>>>>         dev_queue_xmit() and the other IP output functions expect to 
> >> <snip>
> >>> Dave, I'm not sure whether you've missed this or expect it
> >>> to go through Arnaldo, just want to make sure it doesn't
> >>> get missed because of a misunderstanding :)
> >>>
> >>>
> >> If it is not too much work, can you please also remove the two attached
> >> hunks which are now redundant thanks to the above patch.
> >
> >
> > I've added it to the patch, thanks.
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

And for the record, I have it and will merge :-)
