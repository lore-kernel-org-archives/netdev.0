From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Distributed storage. Move away from char device ioctls.
Date: Fri, 14 Sep 2007 17:12:10 -0400
Message-ID: <20070914211210.GB12444@fieldses.org>
References: <20070914185429.GA9439@2ka.mipt.ru> <46EADC02.9070409@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42734 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754597AbXINVMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 17:12:18 -0400
Content-Disposition: inline
In-Reply-To: <46EADC02.9070409@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 14, 2007 at 03:07:46PM -0400, Jeff Garzik wrote:
> My thoughts.  But first a disclaimer:   Perhaps you will recall me as one 
> of the people who really reads all your patches, and examines your code and 
> proposals closely.  So, with that in mind...
>
> I question the value of distributed block services (DBS), whether its your 
> version or the others out there.  DBS are not very useful, because it still 
> relies on a useful filesystem sitting on top of the DBS.  It devolves into 
> one of two cases:  (1) multi-path much like today's SCSI, with distributed 
> filesystem arbitrarion to ensure coherency, or (2) the filesystem running 
> on top of the DBS is on a single host, and thus, a single point of failure 
> (SPOF).
>
> It is quite logical to extend the concepts of RAID across the network, but 
> ultimately you are still bound by the inflexibility and simplicity of the 
> block device.
>
> In contrast, a distributed filesystem offers far more scalability, 
> eliminates single points of failure, and offers more room for optimization 
> and redundancy across the cluster.
>
> A distributed filesystem is also much more complex, which is why 
> distributed block devices are so appealing :)
>
> With a redundant, distributed filesystem, you simply do not need any 
> complexity at all at the block device level.  You don't even need RAID.
>
> It is my hope that you will put your skills towards a distributed 
> filesystem :)  Of the current solutions, GFS (currently in kernel) scales 
> poorly, and NFS v4.1 is amazingly bloated and overly complex.
>
> I've been waiting for years for a smart person to come along and write a 
> POSIX-only distributed filesystem.

What exactly do you mean by "POSIX-only"?

--b.
