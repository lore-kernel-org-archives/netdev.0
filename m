From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] net: Fix memcpy_toiovecend() to use the
 right offset
Date: Mon, 08 Jun 2009 00:28:57 -0700 (PDT)
Message-ID: <20090608.002857.187438966.davem@davemloft.net>
References: <1244230544.1526.77.camel@w-sridhar.beaverton.ibm.com>
	<20090606211321.GC28614@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38345
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753237AbZFHH24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 03:28:56 -0400
In-Reply-To: <20090606211321.GC28614@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 7 Jun 2009 00:13:21 +0300

> On Fri, Jun 05, 2009 at 12:35:44PM -0700, Sridhar Samudrala wrote:
>> Increment the iovec base by the offset passed in for the initial
>> copy_to_user() in memcpy_to_iovecend().
>> 
>> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Applied.
