From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Question]About KVM network zero-copy  feature!
Date: Sat, 11 Aug 2012 13:55:56 -0700
Message-ID: <20120811135556.58ddf48d@nehalam.linuxnetplumber.net>
References: <50248148.4070204@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, avi@redhat.com
To: "Peter Huang(Peng)" <peter.huangpeng@huawei.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <50248148.4070204@huawei.com>
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

On Fri, 10 Aug 2012 11:34:32 +0800
"Peter Huang(Peng)" <peter.huangpeng@huawei.com> wrote:

> Hi,All
> 
> I searched from git-log, and found that until now we have vhost TX zero-copy experiment feature, how
> about RX zero-copy?
> 
> For XEN, net-back also only has TX zero-copy, Is there any reason that RX zero-copy still not implemented?
> 
There is no guarantee that packet will ever be read by receiver. This means zero-copy could
create memory back pressure stalls.
