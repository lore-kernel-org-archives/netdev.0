From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH net] virtio-net: validate features during probe
Date: Wed, 19 Nov 2014 10:14:36 +0100
Message-ID: <20141119101436.3b72989c.cornelia.huck@de.ibm.com>
References: <1416378939-28821-1-git-send-email-jasowang@redhat.com>
	<20141119085939.GB24827@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141119085939.GB24827@redhat.com>
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

On Wed, 19 Nov 2014 10:59:39 +0200
"Michael S. Tsirkin" <mst@redhat.com> wrote:


> +bool __virtnet_fail_on_feature(struct virtio_device *vdev, unsigned int fbit,
> +			       const char *fname)
> +{
> +	if (!virtio_has_feature(vdev, fbit))
> +		return false;
> +
> +        dev_err(&dev->dev, "missing requirements for feature bit %d: %s\n",
> +		fbit, fname);

I'd like the message to point out that this is a hypervisor problem: I
can imagine that a user would be stumped about what to do about this.
And printing what requirements are missing would probably be helpful to
someone trying to fix the hypervisor.

> +
> +	return true;
> +}
> +
>
