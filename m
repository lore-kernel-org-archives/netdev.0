From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net 3/3] gre: receive also TEB packets for lwtunnels
Date: Sat, 23 Apr 2016 15:09:16 +1000
Message-ID: <20160423050912.GA4520@penelope.isobedori.kobe.vergenet.net>
References: <cover.1461346798.git.jbenc@redhat.com>
 <017d8f2b1c00e8fdbdb92a5898b1b5f365b58d6d.1461346798.git.jbenc@redhat.com>
 <20160423014938.GD32327@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org,
	Pravin B Shelar <pshelar@nicira.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:32805 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbcDWFJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 01:09:31 -0400
Received: by mail-pa0-f44.google.com with SMTP id zm5so45688685pac.0
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 22:09:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160423014938.GD32327@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 23, 2016 at 03:49:38AM +0200, Thomas Graf wrote:
> On 04/22/16 at 07:44pm, Jiri Benc wrote:
> > For ipgre interfaces in collect metadata mode, receive also traffic with
> > encapsulated Ethernet headers. The lwtunnel users are supposed to sort this
> > out correctly. This allows to have mixed Ethernet + L3-only traffic on the
> > same lwtunnel interface.
> > 
> > To keep backwards compatibility and prevent any surprises, gretap interfaces
> > have priority in receiving packets with Ethernet headers.
> 
> I may be missing some context. Is anyone using this already or is this
> preparing the stage for another user? It's not clear to me from the
> commit message.

Hi Thomas,

I'm not sure what use Jiri may have in mind but I plan to use
this to allow OvS to support packets without an Ethernet header to
be received from and sent to a GRE tunnel.

I am reasonably sure there are no existing users.
