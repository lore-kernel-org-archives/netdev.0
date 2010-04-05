From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/6] sysfs: Basic support for multiple super blocks
Date: Mon, 05 Apr 2010 16:45:00 +0900
Message-ID: <4BB994FC.1090106@kernel.org>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>	<1269973889-25260-1-git-send-email-ebiederm@xmission.com>	<4BB2E098.7030202@kernel.org> <m1634d82e0.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <m1634d82e0.fsf@fess.ebiederm.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Eric.

On 03/31/2010 02:51 PM, Eric W. Biederman wrote:
>> I haven't looked at later patches but I suppose this is gonna be
>> filled with more meaningful stuff later. 
> 
> Yes it will.
> 
>> One (possibly silly) thing
>> that stands out compared to get_sb_single() is missing remount
>> handling.  Is it intended?
> 
> There is nothing for a remount to do so I ignore it.   The only
> thing that would possibly be meaningful is a read-only mount,
> and nothing I know of sysfs suggests read-only mounts of sysfs
> work, or make any sense.

I see.  Wouldn't it be better to make that design choice evident by
stating the choice in the comment or at least in the patch
description?  As it currently stands, you're burying a clear
functional change in a seemingly innocent patch which contains zero
line of comment and two lines of description.  The same pattern holds
for this whole patchset.  Where are the comments and descriptions
about the design and implementation?  :-(

Thanks.

-- 
tejun
