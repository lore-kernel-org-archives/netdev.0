From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: [RFC] HTB initialize upper bound properly
Date: Fri, 14 Jul 2006 18:06:26 -0400
Message-ID: <1152914786.16981.25.camel@jzny2>
References: <20060714120341.0c7f4466@dxpl.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:58566 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1161174AbWGNWG1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 18:06:27 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1G1Vns-0002fR-2D
	for netdev@vger.kernel.org; Fri, 14 Jul 2006 18:06:32 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060714120341.0c7f4466@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-14-07 at 12:03 -0700, Stephen Hemminger wrote:
> The upper bound for HTB time diff needs to be scaled to PSCHED
> units rather than just assuming usecs.  The field mbuffer is used
> in TDIFF_SAFE(), as an upper bound.  Untested...
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Looks good to me.

cheers,
jamal

