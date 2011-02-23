From: "Jan Beulich" <JBeulich@novell.com>
Subject: Re: [PATCH] cxgb{3,4}: streamline Kconfig options
Date: Wed, 23 Feb 2011 09:46:10 +0000
Message-ID: <4D64E5720200007800033420@vpn.id2.novell.com>
References: <4D5D30CA020000780003263A@vpn.id2.novell.com>
 <20110222.101457.39195901.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <divy@chelsio.com>, <dm@chelsio.com>,
	<linux-kbuild@vger.kernel.org>, <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20110222.101457.39195901.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 22.02.11 at 19:14, David Miller <davem@davemloft.net> wrote:
> From: "Jan Beulich" <JBeulich@novell.com>
> Date: Thu, 17 Feb 2011 13:29:30 +0000
> 
>> The CHELSIO_T{3,4}_DEPENDS options are really awkward, and can be
>> easily dropped if the reverse dependencies of SCSI_CXGB{3,4}_ISCSI on
>> the former get converted to normal (forward) ones referring to
>> CHELSIO_T{3,4}.
>> 
>> Signed-off-by: Jan Beulich <jbeulich@novell.com>
> 
> I think the goal of these strange rules is not to be complicated
> on purpose, but rather to cause the iSCSI drivers to appear without
> the user having to know that he needs to enable the networking
> driver in order for that to happen.

While I realize that this might have been the reason, it's completely
contrary to how everyone else writes dependencies, and hence I
think these should be removed.

Jan

