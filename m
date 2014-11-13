From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 1/2] virito: introduce methods of fixing device features
Date: Thu, 13 Nov 2014 17:49:42 +0800
Message-ID: <54647EB6.5030507@redhat.com>
References: <1415857974-23326-1-git-send-email-jasowang@redhat.com>	<20141113094604.1f248c3d.cornelia.huck@de.ibm.com>	<546475C2.50606@redhat.com>
	<20141113101456.43acfdb7.cornelia.huck@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: Cornelia Huck <cornelia.huck@de.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141113101456.43acfdb7.cornelia.huck@de.ibm.com>
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

On 11/13/2014 05:14 PM, Cornelia Huck wrote:
> On Thu, 13 Nov 2014 17:11:30 +0800
> Jason Wang <jasowang@redhat.com> wrote:
>
>> On 11/13/2014 04:46 PM, Cornelia Huck wrote:
>>> On Thu, 13 Nov 2014 13:52:53 +0800
>>> Jason Wang <jasowang@redhat.com> wrote:
>>>> +static inline void virtio_disable_feature(struct virtio_device *vdev,
>>>> +                                          unsigned int fbit)
>>>> +{
>>>> +	BUG_ON(fbit >= VIRTIO_TRANSPORT_F_START);
>>>> +	BUG_ON(vdev->config->get_status(vdev) &
>>>> +	       ~(VIRTIO_CONFIG_S_ACKNOWLEDGE | VIRTIO_CONFIG_S_DRIVER));
>>> When we add virtio-1 support, we can add a check for FEATURES_OK here,
>>> so we're really on the safe side.
>>>
>> If I read the spec correctly, FEATURES_OK was set only after writing the
>> features bits to device. But we want to sanitize the them before.
> I meant doing a BUG when FEATURES_OK is set - sorry for not being clear.
>

I get it, thanks for the clarification.
