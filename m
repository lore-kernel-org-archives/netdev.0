From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [net-next PATCH] mlx4/mlx5: Use dma_wmb/rmb where appropriate
Date: Tue, 24 Mar 2015 16:33:28 -0700
Message-ID: <5511F448.6090608@redhat.com>
References: <20150323171300.1117.85908.stgit@ahduyck-vm-fedora22> <55112DD9.9030105@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>, Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44445 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752190AbbCXXda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2015 19:33:30 -0400
In-Reply-To: <55112DD9.9030105@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/2015 02:26 AM, Or Gerlitz wrote:
> On 3/23/2015 7:23 PM, Alexander Duyck wrote:
>> [...] I don't have any adapters supported by these drivers so I am 
>> unable to do anything more than build test the changes.
>
> Alex, I'll provide you details on HW access for cards provided to 
> red-hat so you can test the changes.

This patch can be dropped for now.  It looks like we are seeing some 
sort of weird performance glitch on the Rx side where things are running 
faster on average but there is a slow-down for a second or two every 20 
seconds or so which we don't see without the patch.

- Alex
