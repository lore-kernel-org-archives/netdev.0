From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/5] netlink: extended ACK reporting
Date: Thu, 13 Apr 2017 15:29:30 +0200
Message-ID: <1492090170.29526.1.camel@sipsolutions.net>
References: <20170408174900.12820-1-johannes@sipsolutions.net>
         <20170408174900.12820-2-johannes@sipsolutions.net>
         <20170408183440.GA1900@nanopsycho>
         <1491676621.5800.24.camel@sipsolutions.net>
         <20170408184008.GB1900@nanopsycho>
         <990b5610-a894-b3d2-d3a7-536dfd25adb8@cumulusnetworks.com>
         <1491805089.2455.3.camel@sipsolutions.net>
         <c0b35e6e-e5cb-25f6-7ccf-eec33ba39f3b@6wind.com>
         (sfid-20170413_152734_492817_F5A2405F)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>
To: nicolas.dichtel@6wind.com, David Ahern <dsa@cumulusnetworks.com>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55216 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753269AbdDMN3e (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 09:29:34 -0400
In-Reply-To: <c0b35e6e-e5cb-25f6-7ccf-eec33ba39f3b@6wind.com> (sfid-20170413_152734_492817_F5A2405F)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-13 at 15:27 +0200, Nicolas Dichtel wrote:
> 
> > Yes, some - very few - families still insist on using attribute 0,
> > perhaps parsing by hand or so. Like you say though, the entire
> > infrastructure makes that hard and undesirable, so I don't really
> > see
> > why we need to invest the extra code/work into making it work
> > *here*,
> > especially since it's such a corner case as I described in my other
> > email.
> 
> Here is an example:
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/co
> mmit/?id=31e20bad8d58
> 
> I also see one in openvswitch (I will send a similar patch), but
> there are probably some others.

Yeah. I'm not really sure what the point of such a patch is though -
the API is set now, and can't really be changed.

Anyway, the ones you point out are only used for *output* by the
kernel, so wouldn't be affected by any "missing attribute" reporting
anyway.

johannes
