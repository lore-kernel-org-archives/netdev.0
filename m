From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 2/4] bridge: Allow an ability to designate an
 uplink port
Date: Wed, 13 Mar 2013 15:54:50 -0700
Message-ID: <20130313155450.61886850@nehalam.linuxnetplumber.net>
References: <1363139126-13396-1-git-send-email-vyasevic@redhat.com>
	<1363139126-13396-3-git-send-email-vyasevic@redhat.com>
	<20130313203333.GC9821@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:56643 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934317Ab3CMWy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 18:54:56 -0400
Received: by mail-pb0-f50.google.com with SMTP id up1so1467139pbc.23
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 15:54:56 -0700 (PDT)
In-Reply-To: <20130313203333.GC9821@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Mar 2013 22:33:33 +0200
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Tue, Mar 12, 2013 at 09:45:24PM -0400, Vlad Yasevich wrote:
> > Allow a ports to be designated as uplink.  Multiple ports
> > may be designated as uplinks and they will be kept in a
> > list.
> > 
> > Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> 
> It looks like if you make two links uplink, bridging
> between them won't work at all?

Maybe better to mark which ports are terminal ports rather than marking
uplink ports?
