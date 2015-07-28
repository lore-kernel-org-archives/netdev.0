From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] bridge: mdb: add support for vlans
Date: Tue, 28 Jul 2015 16:46:56 -0700
Message-ID: <20150728164656.0b8b66ab@urahara>
References: <1436975120-41319-1-git-send-email-nikolay@cumulusnetworks.com>
	<55B764CF.2070509@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34894 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbbG1Xqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 19:46:46 -0400
Received: by pabkd10 with SMTP id kd10so77315493pab.2
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 16:46:46 -0700 (PDT)
In-Reply-To: <55B764CF.2070509@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Jul 2015 13:17:35 +0200
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> On 07/15/2015 05:45 PM, Nikolay Aleksandrov wrote:
> > This patch allows the user to specify the vlan of the mdb group being
> > added or deleted and adds support for displaying the vlan when
> > dumping mdb information or monitoring it. It also updates the man page
> > to reflect the new "vid" argument for mdb.
> > 
> > Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> > ---
> > note: the cast in print_mdb_entry() was necessary to shut the compiler
> > 
> >  bridge/mdb.c              | 31 +++++++++++++++++++------------
> >  include/linux/if_bridge.h |  1 +
> >  man/man8/bridge.8         |  8 +++++++-
> >  3 files changed, 27 insertions(+), 13 deletions(-)
> > 
> 
> Hi Stephen,
> Just wondering what's the state of this patch because I'd like to submit some
> improvements in the same area and I'm wondering if I should do them on top
> of this patch or if I need to change something in it ?
> 
> Thanks,
>  Nik
> 

Now on net-next branch of iproute2 since support is not in 4.2 kernel.
