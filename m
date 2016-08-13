From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [Intel-wired-lan] [net-next] igb: add function to set I210
 transmit mode
Date: Sat, 13 Aug 2016 18:11:03 +0200
Message-ID: <20160813161103.GA1188@localhost.localdomain>
References: <1470811692-24574-1-git-send-email-gangfeng.huang@ni.com>
 <1470811692-24574-2-git-send-email-gangfeng.huang@ni.com>
 <CAKgT0UeOmzDaLm0-yuvEjzYoN5g8=ouBv+8rpOmx7MgkWRfA+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gangfeng <gangfeng.huang@ni.com>, Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33127 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752630AbcHMQLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2016 12:11:09 -0400
Received: by mail-wm0-f67.google.com with SMTP id o80so3009507wme.0
        for <netdev@vger.kernel.org>; Sat, 13 Aug 2016 09:11:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAKgT0UeOmzDaLm0-yuvEjzYoN5g8=ouBv+8rpOmx7MgkWRfA+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 13, 2016 at 08:27:38AM -0700, Alexander Duyck wrote:
> I really don' think this patch is going to work.  If you are going to
> implement something like this and have a hope to get it accepted into
> the Linux kernel you need to come up with a solution that will work
> fore more than this one device.  We don't want the drivers having to
> carry around their own sysfs controls for things that really are not
> proprietary to the device.  There needs to be a generic kernel
> interface for this.  The fact is something like QAV more than likely
> exists on other devices as well so it may be worth while to look into
> seeing if you could come up with some way of interfacing this with
> either ethtool ,iproute2, or maybe even the DCB/LLDP utilities since
> this is essentially splitting the Tx into two separate traffic
> classes.

Yes to all of this.
 
> Also for these kind of patches it would be best to include the netdev
> mailing list.  That way it can be reviewed by a wider audience and you
> are much more likely to get this accepted upstream rather than have it
> rejected when Jeff Kirsher attempts to submit it.

Right.  We just had a discussion about implementing TSN, and we will
need proper infrastructure in place *before* we start hacking
drivers.

Thanks,
Richard
