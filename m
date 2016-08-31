From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: re-introduce 'fix parsing of MLDv2
	reports'
Date: Wed, 31 Aug 2016 09:30:33 -0700 (PDT)
Message-ID: <20160831.093033.1824547873442883465.davem@davemloft.net>
References: <00146cf9bbd373722167f61183d5d02a9d6c080e.1472644765.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cascardo@redhat.com, nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: dcaratti@redhat.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <00146cf9bbd373722167f61183d5d02a9d6c080e.1472644765.git.dcaratti@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Davide Caratti <dcaratti@redhat.com>
Date: Wed, 31 Aug 2016 14:16:44 +0200

> commit bc8c20acaea1 ("bridge: multicast: treat igmpv3 report with
> INCLUDE and no sources as a leave") seems to have accidentally reverted
> commit 47cc84ce0c2f ("bridge: fix parsing of MLDv2 reports"). This
> commit brings back a change to br_ip6_multicast_mld2_report() where
> parsing of MLDv2 reports stops when the first group is successfully
> added to the MDB cache.
> 
> Fixes: bc8c20acaea1 ("bridge: multicast: treat igmpv3 report with INCLUDE and no sources as a leave")
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>

Applied and queued up for -stable, thanks.
