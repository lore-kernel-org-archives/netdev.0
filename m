From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into
 hardware
Date: Mon, 13 Feb 2012 08:54:31 -0500
Message-ID: <1329141272.9867.4.camel@mojatatu>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>
	 <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>
	 <4F34042F.6090806@intel.com>
	 <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>
	 <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu>
	 <4F347D96.2020806@intel.com> <4F3499BC.8020609@intel.com>
	 <1328887111.2075.43.camel@mojatatu>
	 <20120210083917.5c69637b@nehalam.linuxnetplumber.net>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:55538 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755422Ab2BMNyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 08:54:39 -0500
In-Reply-To: <20120210083917.5c69637b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-02-10 at 08:39 -0800, Stephen Hemminger wrote:

> Some related discussion points:
>  * the bridge needs to support control from both userspace (MSTP, TRILL, ...)
>    and kernel space (offload etc)

I think all are pretty much covered if you let some controler (I prefer
user space) ADD/DEL/GET/Event on the fdb 
TRILL really is outside the scope of this; from an encap/decap it
probably needs to be YAND (Yet another netdev) and from a control side
of things you need to just provide the above netlink ops(ADD, etC) on
the fdb and let the controller worry about things (Actually you _may_
need to have learning done outside of the kernel for TRILL)

>  * the bridge forwarding database is simpler and different than the existing
>    neighbor table, don't remember the details but last time I checked it
>    using neighbor table in bridge would be putting square peg in round hole.

Agreed.

cheers,
jamal
