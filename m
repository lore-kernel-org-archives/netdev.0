From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net 0/2] vxlan: fix error reporting
Date: Fri, 2 Sep 2016 18:41:50 +0200
Message-ID: <20160902184150.03988a34@griffin>
References: <cover.1472815982.git.jbenc@redhat.com>
        <20160902090311.14acb0d1@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58940 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932236AbcIBQly (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 12:41:54 -0400
In-Reply-To: <20160902090311.14acb0d1@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 Sep 2016 09:03:11 -0700, Stephen Hemminger wrote:
> On Fri,  2 Sep 2016 13:37:10 +0200
> Jiri Benc <jbenc@redhat.com> wrote:
> 
> > This patchset improves checking for invalid configuration in VXLAN and fixes
> > problems with duplicated and inappropriate error messages.
> > 
> > Jiri Benc (2):
> >   vxlan: reject multicast destination without an interface
> >   vxlan: fix duplicated and wrong error messages
> > 
> >  drivers/net/vxlan.c | 38 ++++++++++++--------------------------
> >  1 file changed, 12 insertions(+), 26 deletions(-)
> > 
> 
> These should also be detected and rejected in iproute2
> errors in kernel log are user unfriendly api.

I agree and I intend to send a patch once this is accepted.

 Jiri
