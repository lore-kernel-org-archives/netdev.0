From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] kref: add kref_sub_return
Date: Fri, 14 Feb 2014 00:10:04 -0500 (EST)
Message-ID: <20140214.001004.838095636844604151.davem@davemloft.net>
References: <20140212.230506.1305102368255894549.davem@davemloft.net>
	<20140212.230953.770721407102955395.davem@davemloft.net>
	<20140214000320.GC15564@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtio-dev@lists.oasis-open.org, anatol.pomozov@gmail.com, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, qinchuanyu@huawei.com,
	joern@logfs.org
To: gregkh@linuxfoundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20140214000320.GC15564@kroah.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Greg KH <gregkh@linuxfoundation.org>
Date: Thu, 13 Feb 2014 16:03:20 -0800

> So how about just "open coding" a kref for this structure, as it wants
> something that doesn't fit into the kref model, and should be pretty
> simple to do (you can ensure you get the locking right, unlike almost
> all users of krefs, as Al Viro constantly points out to me...)

They redid their patches meanwhile to use their own atomic_t.
