From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH 0/2] vhot-net: Use kvm_memslots instead of vhost_memory
	to translate GPA to HVA
Date: Fri, 16 Dec 2011 10:07:28 +0200
Message-ID: <1324022848.4496.27.camel@lappy>
References: <1324013528-3663-1-git-send-email-zanghongyong@huawei.com>
	<1324019151.4496.9.camel@lappy> <4EEAF5D1.2080805@huawei.com>
	<1324022358.4496.25.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wusongwei@huawei.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, hanweidong@huawei.com,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	xiaowei.yang@huawei.com
To: Zang Hongyong <zanghongyong@huawei.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1324022358.4496.25.camel@lappy>
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

On Fri, 2011-12-16 at 09:59 +0200, Sasha Levin wrote:
> There has been a great deal of effort to keep vhost and kvm untangled.
> One example is the memory translation it has to do, another one is the
> eventfd/irqfd thing it does just so it could signal an IRQ in the guest
> instead of accessing the guest directly.

Actually, CONFIG_VHOST_NET doesn't even depend on CONFIG_KVM, so your
patch will break build when (CONFIG_VHOST_NET=y && CONFIG_KVM=n).

-- 

Sasha.
