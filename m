From: Jeff Garzik <jeff@garzik.org>
Subject: Re: POHMELFS high performance network filesystem. Cache coherency,
 transactions, parallels.
Date: Mon, 26 May 2008 03:51:23 -0400
Message-ID: <483A6BFB.1080209@garzik.org>
References: <20080525134055.GA30630@2ka.mipt.ru> <483A0F3B.9060709@garzik.org> <20080526062204.GA16366@2ka.mipt.ru> <483A59D7.7020306@garzik.org> <20080526070708.GB16366@2ka.mipt.ru> <483A667F.7070707@garzik.org> <20080526074424.GA555@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43601 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752753AbYEZHvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 03:51:25 -0400
In-Reply-To: <20080526074424.GA555@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov wrote:
> On Mon, May 26, 2008 at 03:27:59AM -0400, Jeff Garzik (jeff@garzik.org) wrote:
>> git-update-server-info needs to be run on the server, not the client.
>>
>> You can automate this by running this on the server:
>>
>> 	chmod +x .git/hooks/post-update
>>
>> so that git-update-server-info always runs on the server, after each push.
>>
>> See git-update-server-info(1) for more info.
> 
> Hmm... Nothing can be run on server, since git does not believe it is in
> git repo:

Sorry, I should have mentioned, you need to set GIT_DIR environment 
variable, for this case.  e.g.

	cd /home/s0mbre/archive/pohmelfs
	GIT_DIR=pohmelfs.git git-update-server-info

or

	cd /home/s0mbre/archive/pohmelfs/pohmelfs.git
	GIT_DIR=. git-update-server-info

Regards,

	Jeff


