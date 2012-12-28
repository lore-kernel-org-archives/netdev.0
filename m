From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 2/2] vhost: handle polling failure
Date: Fri, 28 Dec 2012 12:29:25 +0800
Message-ID: <50DD2025.1050004@redhat.com>
References: <1356590360-32770-1-git-send-email-jasowang@redhat.com>
	<1356590360-32770-2-git-send-email-jasowang@redhat.com>
	<50DC1C8F.3020008@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
To: gaowanlong@cn.fujitsu.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <50DC1C8F.3020008@cn.fujitsu.com>
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

On 12/27/2012 06:01 PM, Wanlong Gao wrote:
> On 12/27/2012 02:39 PM, Jason Wang wrote:
>> > Currently, polling error were ignored in vhost. This may lead some issues (e.g
>> > kenrel crash when passing a tap fd to vhost before calling TUNSETIFF). Fix this
>> > by:
> Can this kernel crash be reproduced by hand?
>
> Thanks,
> Wanlong Gao
>
>> > 
Yes, it could be simply reproduced by: open a tap fd but does not cal
TUNSETIFF, then pass it to qemu and enable vhost.
