From: Avi Kivity <avi@redhat.com>
Subject: Re: performance regression in virtio-net in 2.6.32-rc4
Date: Tue, 27 Oct 2009 11:41:25 +0200
Message-ID: <4AE6C045.1070800@redhat.com>
References: <20091026184835.GB26473@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49465 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750786AbZJ0Jl2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2009 05:41:28 -0400
In-Reply-To: <20091026184835.GB26473@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2009 08:48 PM, Michael S. Tsirkin wrote:
> Hi!
> I noticed a performance regression in virtio net: going from
> 2.6.31 to 2.6.32-rc4 I see this, for guest to host communication:
>
> Any tips on debugging this?
>    

Lacking better advice, a bisect can help as a last resort.  'git bisect 
start -- drivers/net drivers/virtio' will probably find it fastest.

-- 
error compiling committee.c: too many arguments to function

