From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dlm, sctp: Do not allocate a fd for peeloff
Date: Thu, 08 Mar 2012 00:24:47 -0800 (PST)
Message-ID: <20120308.002447.1062706659978103072.davem@davemloft.net>
References: <1331134862-14812-1-git-send-email-bpoirier@suse.de>
	<4F578CE0.6030106@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bpoirier@suse.de, ccaulfie@redhat.com, teigland@redhat.com,
	sri@us.ibm.com, cluster-devel@redhat.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F578CE0.6030106@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 07 Mar 2012 11:29:20 -0500

> On 03/07/2012 10:41 AM, Benjamin Poirier wrote:
>> avoids allocating a fd that a) propagates to every kernel thread and
>> usermodehelper b) is not properly released.
>> 
>> References: http://article.gmane.org/gmane.linux.network.drbd/22529
>> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
> 
> It might make sense to change sctp_do_peeloff to take the association id as
> the first argument and not do the mapping from id to association yourself.
> It's a bit ugly to expose internal sctp structures outside of SCTP.

Agreed.
