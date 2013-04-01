From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH]  net-sysfs: make flags symmetrical
Date: Mon, 1 Apr 2013 15:04:07 -0700
Message-ID: <20130401150407.0d689980@nehalam.linuxnetplumber.net>
References: <20130401115315.1f8e4213@nehalam.linuxnetplumber.net>
	<5159EB2B.7070504@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:39121 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758036Ab3DAWEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 18:04:24 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz11so1538441pad.16
        for <netdev@vger.kernel.org>; Mon, 01 Apr 2013 15:04:24 -0700 (PDT)
In-Reply-To: <5159EB2B.7070504@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 01 Apr 2013 13:16:43 -0700
Ben Greear <greearb@candelatech.com> wrote:

> On 04/01/2013 11:53 AM, Stephen Hemminger wrote:
> > The flags reported by sysfs are the raw kernel flags, not the version
> > exported to user space. This leads to the unsymmetrical behaviour that
> > read != write. An example of this is when a device is part of a
> > bridge.  The PROMISC flag returned from sysfs will not be the same as
> > other API's.
> >
> > The reason this patch deserves wider discussion is someone might be
> > depending on sysfs to read raw kernel flags.
> 
> I am depending on this feature.  There is no other way I know
> of to determine if an interface is actually currently acting
> PROMISC or not.
> 
> Please don't 'fix' this.
> 
> Thanks,
> Ben
> 

The real problem is there isn't a netlink attribute that encodes
the real flags (there should be), and when device changes state a notification
should be sent.
