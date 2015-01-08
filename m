From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost/net: length miscalculation
Date: Thu, 8 Jan 2015 10:08:29 +0200
Message-ID: <20150108080829.GA12425@redhat.com>
References: <1420620847-24477-1-git-send-email-mst@redhat.com>
	<54AD9DD8.2080008@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <54AD9DD8.2080008@cogentembedded.com>
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

On Wed, Jan 07, 2015 at 11:58:00PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 01/07/2015 11:55 AM, Michael S. Tsirkin wrote:
> 
> >commit 8b38694a2dc8b18374310df50174f1e4376d6824
> >     vhost/net: virtio 1.0 byte swap
> >had this chunk:
> >-       heads[headcount - 1].len += datalen;
> >+       heads[headcount - 1].len = cpu_to_vhost32(vq, len - datalen);
> 
> >This adds datalen with the wrong sign, causing guest panics.
> 
> >Fixes: 8b38694a2dc8b18374310df50174f1e4376d6824
> 
>    The format of this tag assumes 12-digit SHA1 hash and the commit
> description enclosed in parens and double quotes. See
> Documentation/SubmittingPatches.
> 
> >Reported-by: Alex Williamson <alex.williamson@redhat.com>
> >Suggested-by: Greg Kurz <gkurz@linux.vnet.ibm.com>
> >Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> WBR, Sergei

I pushed the patches to Linus unfortunately - there's
some urgency since many people are hitting the bug.
Will do my best to do it right next time.

-- 
MST
