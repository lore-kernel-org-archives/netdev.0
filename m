From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next rfc V2 0/2] basic busy polling support for
	vhost_net
Date: Fri, 30 Oct 2015 19:58:30 +0800
Message-ID: <56335B66.9050705@redhat.com>
References: <1446108326-37765-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1446108326-37765-1-git-send-email-jasowang@redhat.com>
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



On 10/29/2015 04:45 PM, Jason Wang wrote:
> Hi all:
>
> This series tries to add basic busy polling for vhost net. The idea is
> simple: at the end of tx processing, busy polling for new tx added
> descriptor and rx receive socket for a while. The maximum number of
> time (in us) could be spent on busy polling was specified through
> module parameter.
>
> Test were done through:
>
> - 50 us as busy loop timeout
> - Netperf 2.6
> - Two machines with back to back connected mlx4
> - Guest with 8 vcpus and 1 queue
>
> Result shows very huge improvement on both tx (at most 158%) and rr
> (at most 53%) while rx is as much as in the past. Most cases the cpu
> utilization is also improved:
>

Just notice there's something wrong in the setup. So the numbers are
incorrect here. Will re-run and post correct number here.

Sorry.
