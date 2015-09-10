From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/4] vhost: move features to core
Date: Thu, 10 Sep 2015 22:15:05 +0300
Message-ID: <55F1D6B9.3010007@cogentembedded.com>
References: <1441869802-15847-1-git-send-email-mst@redhat.com>
	<1441869802-15847-3-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Xie, Huawei" <huawei.xie@intel.com>,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1441869802-15847-3-git-send-email-mst@redhat.com>
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

Hello.

On 09/10/2015 10:23 AM, Michael S. Tsirkin wrote:

> virtio 1 and any layout are core features, move them
> there. This fixes vhost test.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

[...]
> diff --git a/drivers/vhost/test.c b/drivers/vhost/test.c
> index d9c501e..f2882ac 100644
> --- a/drivers/vhost/test.c
> +++ b/drivers/vhost/test.c
> @@ -277,10 +277,13 @@ static long vhost_test_ioctl(struct file *f, unsigned int ioctl,
>   			return -EFAULT;
>   		return 0;
>   	case VHOST_SET_FEATURES:
> +		printk(KERN_ERR "1\n");
>   		if (copy_from_user(&features, featurep, sizeof features))
>   			return -EFAULT;
> +		printk(KERN_ERR "2\n");
>   		if (features & ~VHOST_FEATURES)
>   			return -EOPNOTSUPP;
> +		printk(KERN_ERR "3\n");
>   		return vhost_test_set_features(n, features);
>   	case VHOST_RESET_OWNER:
>   		return vhost_test_reset_owner(n);

    Debugging printk's remained?

MBR, Sergei
