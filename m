From: Dave Jones <davej@redhat.com>
Subject: Re: [Qemu-devel] [PATCH] virtio-net: put virtio net header inline
	with data
Date: Thu, 6 Jun 2013 16:09:33 -0400
Message-ID: <20130606200932.GB3837@redhat.com>
References: <20130606095456.GA7865@redhat.com>
	<51B0EA30.3020804@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	qemu-devel@nongnu.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>
To: Jesse Larrew <jlarrew@linux.vnet.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <51B0EA30.3020804@linux.vnet.ibm.com>
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

On Thu, Jun 06, 2013 at 02:59:44PM -0500, Jesse Larrew wrote:
 
 > >  	pr_debug("%s: xmit %p %pM\n", vi->dev->name, skb, dest);
 > > +	if (vi->mergeable_rx_bufs)
 > > +		hdr_len = sizeof hdr->mhdr;
 > > +	else
 > > +		hdr_len = sizeof hdr->hdr;
 > 
 > All conditionals need braces.
 
Documentation/CodingStyle disagrees:

 "Do not unnecessarily use braces where a single statement will do."
 
	Dave 
