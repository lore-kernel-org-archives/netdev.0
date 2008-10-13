From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [IPROUTE]: Fix up "ip link" help text
Date: Mon, 13 Oct 2008 07:21:29 -0700
Message-ID: <20081013072129.2564130f@extreme>
References: <48EB7D76.7050004@trash.net>
	<200810072206.03062.arekm@maven.pl>
	<48EBCE59.3080401@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arkadiusz Miskiewicz <arekm@maven.pl>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37796 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751399AbYJMOVb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2008 10:21:31 -0400
In-Reply-To: <48EBCE59.3080401@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 07 Oct 2008 23:02:17 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Arkadiusz Miskiewicz wrote:
> > Runtime dependand help doesn't look sane. Help should always show all possible 
> > options/command while trying to use unsupported option should display error 
> > message.
> >   
> 
> That makes sense. But don't complain to me about the quality
> of the error messages afterwards please :)
> 
> 

I applied a variant of Patrick's original patch. I added text for delete, and
avoided some code movement.  The help text should only show what is supported
otherwise there will be user complaints.
