From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Question regarding linux networking
Date: Wed, 10 Jun 2009 11:09:01 +0000
Message-ID: <20090610110901.GC2673@ff.dom.local>
References: <a05f5a000906090520y2b8b635epd1ef0f04c8d86fa7@mail.gmail.com> <20090610063749.GA2673@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, acme@redhat.com, nhorman@tuxdriver.com
To: sampath kumar <sampath.in@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:64047 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754784AbZFJLJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 07:09:07 -0400
Received: by ewy6 with SMTP id 6so881769ewy.37
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 04:09:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090610063749.GA2673@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2009 at 06:37:49AM +0000, Jarek Poplawski wrote:
> On Tue, Jun 09, 2009 at 05:50:09PM +0530, sampath kumar wrote:
...
> > I'm trying to use/understand linux networking code. Say for example decnet,
> > phonet etc, in order to register a device we need to send an RTM_NEWADDR msg
> > to the kernel.
> > 
> > do I've to send it from kernel space or user space ? If I check the code of
> > decnet or phonet, each have registered using rtnl_register an addr_doit func
> > after reception of RTM_NEWADDR msg. how do i send this msg and from where ??

You can send it both from kernel and user space. For user space
usage have a look at iproute2 sources. And here is a general
description: http://people.redhat.com/nhorman/papers/netlink.pdf

Jarek P.
