From: Jiri Benc <jbenc@redhat.com>
Subject: Re: Delivery Status Notification (Failure)
Date: Thu, 24 Sep 2015 15:09:06 +0200
Message-ID: <20150924150906.067bba62@griffin>
References: <047d7b5dbb76a0065405207cfe24@google.com>
	<CAOLDph0pO0q3A4-mRjn3wkGvHP5c9anBWbaDBDOLhVRz+JVDMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Naveen <dear.chap@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33487 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754954AbbIXNJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 09:09:09 -0400
In-Reply-To: <CAOLDph0pO0q3A4-mRjn3wkGvHP5c9anBWbaDBDOLhVRz+JVDMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Sep 2015 08:03:39 -0400, Naveen wrote:
>      Right now the only way to detect if an interface has a peer(veth)
> is touse ethtool -S. Instead I was thinking of adding it to device
> attributes as a peer_ifndex entry. In drivers/net/veth.c I could add
> an entry to
> dev->groups for a veth specific group. Would that be acceptable ?

Recent kernels announce the peer in IFLA_LINK, including its netnsid
(thus it's finally possible to track peers across net namespaces).
Just try "ip a" with a recent kernel.

 Jiri

-- 
Jiri Benc
