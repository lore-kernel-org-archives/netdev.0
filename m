From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: per-PID network stats files in /proc
Date: Tue, 24 Sep 2013 14:02:29 -0700
Message-ID: <1380056549.3165.117.camel@edumazet-glaptop>
References: <20130924201536.GA3555@mhcomputing.net>
	 <20130924134157.4fc22806@nehalam.linuxnetplumber.net>
	 <20130924204442.GA5074@mhcomputing.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Matthew Hall <mh@mhcomputing.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:33208 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753657Ab3IXVCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 17:02:30 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb4so5080101pbc.22
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 14:02:30 -0700 (PDT)
In-Reply-To: <20130924204442.GA5074@mhcomputing.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 13:44 -0700, Matthew Hall wrote:
> On Tue, Sep 24, 2013 at 01:41:57PM -0700, Stephen Hemminger wrote:
> > No. because most of these would be associated with global state.
> > Even sockets can be shared between PID's.
> 
> OK. So if this is true, then I feel compelled to ask, why does 
> /proc/PID/net/snmp exist in the first place, if it would never really work?

That because of network containers

You can perfectly use a network container to get your own copy of
counters

ip netns help
