From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH] virtio_net: XDP support for adjust_head
Date: Fri, 23 Dec 2016 13:46:54 -0800
Message-ID: <585D9B4E.8080209@gmail.com>
References: <20161223184301.26974.68383.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com, daniel@iogearbox.net,
	virtualization@lists.linux-foundation.org
To: jasowang@redhat.com, jakub.kicinski@netronome.com, mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20161223184301.26974.68383.stgit@john-Precision-Tower-5810>
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

On 16-12-23 10:43 AM, John Fastabend wrote:
> Add support for XDP adjust head by allocating a 256B header region
> that XDP programs can grow into. This is only enabled when a XDP
> program is loaded.
> 
> In order to ensure that we do not have to unwind queue headroom push
> queue setup below bpf_prog_add. It reads better to do a prog ref
> unwind vs another queue setup call.
> 
> TBD merge with Jason Wang's fixes, do a bit more testing, note
>     big_packet support is removed by Jason as well.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  drivers/net/virtio_net.c |   53 +++++++++++++++++++++++++++++++---------------
>  1 file changed, 36 insertions(+), 17 deletions(-)
> 

ah dang, I sent this from the wrong tree so it was missing a fix sorry
for the noise. I'll send an update on top of net shortly.

.John
