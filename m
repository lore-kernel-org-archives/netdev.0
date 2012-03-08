From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] dlm: Do not allocate a fd for peeloff
Date: Thu, 08 Mar 2012 13:52:46 -0800 (PST)
Message-ID: <20120308.135246.1582619301405301344.davem@davemloft.net>
References: <1331222159-28980-1-git-send-email-bpoirier@suse.de>
	<1331222159-28980-2-git-send-email-bpoirier@suse.de>
	<4F5911B1.6050600@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bpoirier@suse.de, ccaulfie@redhat.com, teigland@redhat.com,
	sri@us.ibm.com, cluster-devel@redhat.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F5911B1.6050600@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 08 Mar 2012 15:08:17 -0500

> On 03/08/2012 10:55 AM, Benjamin Poirier wrote:
>> avoids allocating a fd that a) propagates to every kernel thread and
>> usermodehelper b) is not properly released.
>> 
>> References: http://article.gmane.org/gmane.linux.network.drbd/22529
>> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
> 
> Looks much better.

Also applied to net-next, thanks.
