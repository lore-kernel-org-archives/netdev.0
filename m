From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] cls_u32: fix sparse warnings
Date: Wed, 23 Feb 2011 10:16:14 -0800
Message-ID: <20110223101614.1cdc9d51@nehalam>
References: <20110220181423.492594b7@nehalam>
	<1298464542.2271.1.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36628 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753621Ab1BWSQR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 13:16:17 -0500
In-Reply-To: <1298464542.2271.1.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Feb 2011 07:35:42 -0500
jamal <hadi@cyberus.ca> wrote:

> On Sun, 2011-02-20 at 18:14 -0800, Stephen Hemminger wrote:
> > The variable _data is used in asm-generic to define sections
> > which causes sparse warnings, so just rename the variable.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>
> 
> Hey, while you are sparsing away you may wanna fix 
> br_fdb_cleanup() as well ;-> /me runs
> 

With current sparse and net-next it comes up clean.
