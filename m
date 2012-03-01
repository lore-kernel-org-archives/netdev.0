From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into
 hardware
Date: Thu, 01 Mar 2012 08:36:20 -0500
Message-ID: <1330608980.6944.27.camel@mojatatu>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>
	 <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>
	 <4F34042F.6090806@intel.com>
	 <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>
	 <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu>
	 <4F347D96.2020806@intel.com> <4F3499BC.8020609@intel.com>
	 <1328887111.2075.43.camel@mojatatu> <4F39287F.6030204@intel.com>
	 <1329225526.2806.34.camel@mojatatu> <4F3AAE80.4040609@intel.com>
	 <1329315057.4158.15.camel@mojatatu> <4F3C5B44.7000608@intel.com>
	 <1329488932.2272.19.camel@mojatatu> <4F3E8A01.5000205@intel.com>
	 <1329568900.3027.0.camel@mojatatu> <4F4DAC26.4050108@intel.com>
	 <1330523779.18226.17.camel@mojatatu> <4F4E5FA4.4040506@intel.com>
	 <20120229095204.48885405@nehalam.linuxnetplumber.net>
	 <4F4E6C44.9070502@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com, kernel@wantstofly.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:50683 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759292Ab2CANgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 08:36:24 -0500
Received: by iagz16 with SMTP id z16so805569iag.19
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2012 05:36:24 -0800 (PST)
In-Reply-To: <4F4E6C44.9070502@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-02-29 at 10:19 -0800, John Fastabend wrote:

> > 
> > I want to see a unified API so that user space control applications (RSTP, TRILL?)
> > can use one set of netlink calls for both software bridge and hardware offloaded
> > bridges.  Does this proposal meet that requirement?
> > 

I dont see any issues with those requirements being met.

> Jamal, so why do "They have to be different calls"? I'm not so sure anymore...
> moving to RTM_FDB_XXXENTRY saved some refactoring in the bridge module but that
> is just cosmetic.

I may not want to use the s/ware bridge i.e I may want to use h/ware
bridge. I may want to use both. So there are 3 variations there. You
need at least 1.5 bits to represent them if you are going to use the
same interface. There may be features in either h/ware but not in
s/ware and vice-versa. 
A single interface with flags which say this applies to hware:sware:both
would be good, but it may be harder to achieve - thats why i suggested
they be different.

cheers,
jamal
