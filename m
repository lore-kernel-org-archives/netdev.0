From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] bridge and friends: reduce TheLinuxWay(tm)
Date: Wed, 16 Oct 2013 11:49:34 -0700
Message-ID: <20131016114934.2265dbe5@nehalam.linuxnetplumber.net>
References: <525C62D5.3090004@mojatatu.com>
	<20131014144156.6dc52a78@nehalam.linuxnetplumber.net>
	<525E9AB1.6090502@mojatatu.com>
	<525EC8AF.6000902@redhat.com>
	<525ED1AE.7050101@mojatatu.com>
	<1381948550.2045.136.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, vyasevic@redhat.com,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:41534 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759631Ab3JPSti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 14:49:38 -0400
Received: by mail-pd0-f182.google.com with SMTP id q10so582524pdj.41
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 11:49:38 -0700 (PDT)
In-Reply-To: <1381948550.2045.136.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Oct 2013 11:35:50 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2013-10-16 at 13:49 -0400, Jamal Hadi Salim wrote:
> 
> > I think we need some filtering in the kernel. As it stands today,
> > unfortunately you get everything ;-> I was suprised at the amount of
> > data i get from the kernel these days when i ask for a simple netdev
> > info (I think no less than 1K per netdev; everything from /proc entries
> > from some bread crumbs i dont see any use for.
> 
> By the way, "ip link show dev xxxx" seems to dump all devices info from
> the kernel...
> 
> 
As I remember.

The problem is that according to original netlink design there is supposed to
be a NLM_F_MATCH, but it seems it never got implemented right, and the legacy
of breaking applications keeps it from happening.
