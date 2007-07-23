From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 04/10] net-sysfs.c changes.
Date: Mon, 23 Jul 2007 10:56:29 +0100
Message-ID: <20070723105629.278fcce3@oldman.hamilton.local>
References: <20070720172203.0eaeea86@oldman>
	<OFFAA4E4C4.F1496A54-ON6525731F.0025194E-6525731F.0025379C@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, Patrick McHardy <kaber@trash.net>,
	kumarkr@linux.ibm.com, mcarlson@broadcom.com, mchan@broadcom.com,
	netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	rdreier@cisco.com, rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	sri@us.ibm.com, tgraf@suug.ch, xma@us.ibm.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46510 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752227AbXGWJ6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 05:58:09 -0400
In-Reply-To: <OFFAA4E4C4.F1496A54-ON6525731F.0025194E-6525731F.0025379C@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 21 Jul 2007 12:16:30 +0530
Krishna Kumar2 <krkumar2@in.ibm.com> wrote:

> Stephen Hemminger <shemminger@linux-foundation.org> wrote on 07/20/2007
> 09:52:03 PM:
> > Patrick McHardy <kaber@trash.net> wrote:
> >
> > > Krishna Kumar2 wrote:
> > > > Patrick McHardy <kaber@trash.net> wrote on 07/20/2007 03:37:20 PM:
> > > >
> > > >
> > > >
> > > >> rtnetlink support seems more important than sysfs to me.
> > > >>
> > > >
> > > > Thanks, I will add that as a patch. The reason to add to sysfs is
> that
> > > > it is easier to change for a user (and similar to tx_queue_len).
> > > >
> > >
> >
> > But since batching is so similar to TSO, i really should be part of the
> > flags and controlled by ethtool like other offload flags.
> 
> So should I add all three interfaces (or which ones) :
> 
>       1. /sys (like for tx_queue_len)
>       2. netlink
>       3. ethtool.
> 
> Or only 2 & 3 are enough ?
> 

Yes, please do #3 and maybe #2.
Sysfs api's are a long term ABI problem.
