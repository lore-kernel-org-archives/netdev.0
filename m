From: Jesse Larrew <jlarrew@linux.vnet.ibm.com>
Subject: Re: [PATCH] virtio-net: put virtio net header inline
 with data
Date: Thu, 06 Jun 2013 15:18:13 -0500
Message-ID: <51B0EE85.1000905@linux.vnet.ibm.com>
References: <20130606095456.GA7865@redhat.com>
	<51B0EA30.3020804@linux.vnet.ibm.com>
	<20130606200932.GB3837@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Dave Jones <davej@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>, Cong Wang <amwang@redhat.com>,
	Amos Kong <akong@redhat.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, qemu-devel@nongnu.org
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20130606200932.GB3837@redhat.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

On 06/06/2013 03:09 PM, Dave Jones wrote:
> On Thu, Jun 06, 2013 at 02:59:44PM -0500, Jesse Larrew wrote:
> 
>  > >  	pr_debug("%s: xmit %p %pM\n", vi->dev->name, skb, dest);
>  > > +	if (vi->mergeable_rx_bufs)
>  > > +		hdr_len = sizeof hdr->mhdr;
>  > > +	else
>  > > +		hdr_len = sizeof hdr->hdr;
>  > 
>  > All conditionals need braces.
> 
> Documentation/CodingStyle disagrees:
> 
>  "Do not unnecessarily use braces where a single statement will do."
> 
> 	Dave 
> 

Ah, yes. This is kernel code. My mistake. :)

Jesse Larrew
Software Engineer, KVM Team
IBM Linux Technology Center
Phone: (512) 973-2052 (T/L: 363-2052)
jlarrew@linux.vnet.ibm.com
