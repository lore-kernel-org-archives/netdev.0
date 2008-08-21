From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/8] netns: Enable tagging for net_class directories in
 sysfs
Date: Wed, 20 Aug 2008 23:47:19 -0700 (PDT)
Message-ID: <20080820.234719.243864265.davem@davemloft.net>
References: <m14p5e27tb.fsf_-_@frodo.ebiederm.org>
	<m1vdxuzxco.fsf_-_@frodo.ebiederm.org>
	<m1r68izxbi.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, gregkh@suse.de, akpm@linux-foundation.org,
	htejun@gmail.com, dlezcano@fr.ibm.com,
	linux-kernel@vger.kernel.org, viro@ftp.linux.org.uk,
	containers@lists.osdl.org, benjamin.thery@bull.net,
	netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54274
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758234AbYHUGrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 02:47:20 -0400
In-Reply-To: <m1r68izxbi.fsf_-_@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 20 Aug 2008 23:39:13 -0700

> 
> The problem.  Network devices show up in sysfs and with the network
> namespace active multiple devices with the same name can show up in
> the same directory, ouch!
> 
> To avoid that problem and allow existing applications in network namespaces
> to see the same interface that is currently presented in sysfs, this
> patch enables the tagging directory support in sysfs.
> 
> By using the network namespace pointers as tags to separate out the
> the sysfs directory entries we ensure that we don't have conflicts
> in the directories and applications only see a limited set of
> the network devices.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Acked-by: David S. Miller <davem@davemloft.net>
