From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: 3.10.0-rc2 mlx4 not receiving packets for some multicast groups
Date: Sat, 25 May 2013 06:41:05 +0300
Message-ID: <CAJZOPZJwe6xAj7xRK5_BnWN2wNT+oVS329+iYtE4hYTqPMLwJQ@mail.gmail.com>
References: <20130524154931.GA9245@sbohrermbp13-local.rgmadvisors.com>
	<20130524163446.GC9245@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:61773 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754625Ab3EYDlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 23:41:07 -0400
Received: by mail-qa0-f52.google.com with SMTP id bv4so239137qab.18
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 20:41:06 -0700 (PDT)
In-Reply-To: <20130524163446.GC9245@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 24, 2013 at 7:34 PM, Shawn Bohrer <shawn.bohrer@gmail.com> wrote:
> On Fri, May 24, 2013 at 10:49:31AM -0500, Shawn Bohrer wrote:
> > I just started testing the 3.10 kernel, previously we were on 3.4 so
> > there is a fairly large jump.  I've additionally applied the following
> > four patches to the 3.10.0-rc2 kernel that I'm testing:
> >
> > https://patchwork.kernel.org/patch/2484651/
> > https://patchwork.kernel.org/patch/2484671/
> > https://patchwork.kernel.org/patch/2484681/
> > https://patchwork.kernel.org/patch/2484641/
> >
>> I don't know if those patches are related to my issues or not but I
>> plan on trying to reproduce without them soon.

> I've reverted the four patches above from my test kernel and still see
> the issue so they don't appear to be the cause.

Hi Shawn,

So 3.4 works, 3.10-rc2 breaks? its indeed a fairly large gap, maybe
try to bisec that? just to make sure, did use touch any mlx4
non-default config? specifically did you turn DMFS (Device Managed
Flow Steering) on using the  set the mlx4_core module param of
log_num_mgm_entry_size or you were using B0 steering (the default)?

Or.
