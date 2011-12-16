From: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
Subject: Re: [PATCH 0/2] vhot-net: Use kvm_memslots instead of vhost_memory
	to translate GPA to HVA
Date: Fri, 16 Dec 2011 16:05:50 +0900
Message-ID: <4EEAEDCE.3030109@oss.ntt.co.jp>
References: <1324013528-3663-1-git-send-email-zanghongyong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wusongwei@huawei.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, hanweidong@huawei.com,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	xiaowei.yang@huawei.com, levinsasha928@gmail.com
To: zanghongyong@huawei.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1324013528-3663-1-git-send-email-zanghongyong@huawei.com>
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

(2011/12/16 14:32), zanghongyong@huawei.com wrote:
> From: Hongyong Zang<zanghongyong@huawei.com>
> 
> Vhost-net uses its own vhost_memory, which results from user space (qemu) info,
> to translate GPA to HVA. Since kernel's kvm structure already maintains the
> address relationship in its member *kvm_memslots*, these patches use kernel's
> kvm_memslots directly without the need of initialization and maintenance of
> vhost_memory.

Isn't vhost independent from KVM?

	Takuya
