From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into
 hardware
Date: Sat, 18 Feb 2012 07:41:40 -0500
Message-ID: <1329568900.3027.0.camel@mojatatu>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>
	 <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>
	 <4F34042F.6090806@intel.com>
	 <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>
	 <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu>
	 <4F347D96.2020806@intel.com>  <4F3499BC.8020609@intel.com>
	 <1328887111.2075.43.camel@mojatatu>  <4F39287F.6030204@intel.com>
	 <1329225526.2806.34.camel@mojatatu>  <4F3AAE80.4040609@intel.com>
	 <1329315057.4158.15.camel@mojatatu>  <4F3C5B44.7000608@intel.com>
	 <1329488932.2272.19.camel@mojatatu>  <4F3E8A01.5000205@intel.com>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:39504 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588Ab2BRMlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2012 07:41:47 -0500
In-Reply-To: <4F3E8A01.5000205@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-02-17 at 09:10 -0800, John Fastabend wrote:

> Yes I agree that is the goal.
> 
> > One last comment:
> > With synchronization there are other challenges when the entry in the
> > hardware conflicts with the entry in software when you intend the
> > behavior to be the same. This is not such a big deal with bridging but
> > becomes more apparent when you start offloading ACLs etc.
> > 
> 
> OK and these sorts of conflicts certainly don't need to be resolved
> by kernel code. So I think this is a reasonable reason to drive the
> synchronization into a user space daemon.


Yep. 
Thanks for listening John. Waiting to see them patches.

cheers,
jamal
