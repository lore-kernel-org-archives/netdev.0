From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Vlan interface nuisance
Date: Mon, 2 Mar 2009 13:51:01 -0800
Message-ID: <20090302135101.1165f117@nehalam>
References: <20090301204731.40ce346a@nehalam>
	<20090302172057.GA23247@csclub.uwaterloo.ca>
	<49AC2A9C.5090303@gmail.com>
	<49AC545E.3090708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49020 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752096AbZCBVvF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 16:51:05 -0500
In-Reply-To: <49AC545E.3090708@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 02 Mar 2009 22:49:18 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Jarek Poplawski wrote:
> > Lennart Sorensen wrote, On 03/02/2009 06:20 PM:
> > 
> >> On Sun, Mar 01, 2009 at 08:47:31PM -0800, Stephen Hemminger wrote:
> >>> Why is interface created through netlink named 'vlan0' and
> >>> interface created through old vconfig called 'ethX.YY'.
> >>> Seems like the interface should be consistent.
> >> That does seem silly.
> >>
> >> ethX.YYYY told you which physical interface and which vlan number it was.
> >>
> >> vlan0 tells you nothing useful.
> >  
> > 
> > Even if you have only one ethX?
> 
> The binding is displayed when listing interfaces. This hole
> argument is silly, if you want a particular name, just specify
> it. The current naming schemes are entirely based on information
> that you have to specify anyways.

I overlooked the obvious:
 ip li add link eth1 name eth1.44 type vlan id 44

Setting the name overrides.
