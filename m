From: Jamie Lokier <jamie@shareable.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 22:43:49 +0100
Message-ID: <20080514214347.GD23758@shareable.org>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru> <20080514143105.GB14987@shareable.org> <20080514150052.GA15826@2ka.mipt.ru> <20080514213251.GB23758@shareable.org> <482B5BB6.3040308@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Sage Weil <sage@newdream.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:56711 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752116AbYENVnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 17:43:53 -0400
Content-Disposition: inline
In-Reply-To: <482B5BB6.3040308@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Definitely.  "several leaders" aka partitioning is also becoming 
> increasing paired with efforts at enhancing locality of reference.  Both 
> Google and Amazon sort their distributed tables lexographically, which 
> [ideally] results in similar data being stored near each other.
> 
> A bit of an improvement over partitioning-by-hash, anyway, for some 
> workloads.

As with B-trees on disks, and in-memory structures, application
knowledge of locality is very much worth passing to the storage layer.

-- Jamie
