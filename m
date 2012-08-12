From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] macvtap: rcu_dereference outside read-lock section
Date: Sun, 12 Aug 2012 13:41:18 -0700 (PDT)
Message-ID: <20120812.134118.90820419749031873.davem@davemloft.net>
References: <20120811.181642.1587792778007257202.davem@davemloft.net>
	<1344752791-21140-1-git-send-email-yefremov.denis@gmail.com>
	<20120812084929.GB4430@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yefremov.denis@gmail.com, jasowang@redhat.com,
	ebiederm@xmission.com, ian.campbell@citrix.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ldv-project@ispras.ru
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120812084929.GB4430@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 12 Aug 2012 11:49:29 +0300

> On Sun, Aug 12, 2012 at 10:26:31AM +0400, Denis Efremov wrote:
>> rcu_dereference occurs in update section. Replacement by
>> rcu_dereference_protected in order to prevent lockdep
>> complaint.
>> 
>> Found by Linux Driver Verification project (linuxtesting.org)
>> 
>> Signed-off-by: Denis Efremov <yefremov.denis@gmail.com>
...
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Applied, thanks everyone.
