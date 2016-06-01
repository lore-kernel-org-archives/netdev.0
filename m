From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] misc: Rename the HASH_SIZE macro
Date: Wed, 01 Jun 2016 11:13:16 -0700 (PDT)
Message-ID: <20160601.111316.1221508960754524502.davem@davemloft.net>
References: <1464767580-22732-1-git-send-email-kernel@kyup.com>
	<1464767580-22732-4-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@johnmccutchan.com, eparis@redhat.com, ebiederm@xmission.com,
	jack@suse.cz, linux-kernel@vger.kernel.org, gorcunov@openvz.org,
	avagin@openvz.org, netdev@vger.kernel.org,
	operations@siteground.com
To: kernel@kyup.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464767580-22732-4-git-send-email-kernel@kyup.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nikolay Borisov <kernel@kyup.com>
Date: Wed,  1 Jun 2016 10:52:59 +0300

> This change is required since the inotify-per-namespace code added
> hashtable.h to the include list of sched.h. This in turn causes
> compiler warnings since HASH_SIZE is being defined in multiple
> locations
> 
> Signed-off-by: Nikolay Borisov <kernel@kyup.com>

Acked-by: David S. Miller <davem@davemloft.net>
