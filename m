From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [net-next RFC V5 4/5] virtio_net: multiqueue support
Date: Sat, 21 Jul 2012 14:02:58 +0200
Message-ID: <500A9A72.20507@gmail.com>
References: <1341484194-8108-1-git-send-email-jasowang@redhat.com>
	<1341484194-8108-5-git-send-email-jasowang@redhat.com>
	<20120720134014.GD16550@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, habanero@linux.vnet.ibm.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, mashirle@us.ibm.com, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	tahm@linux.vnet.ibm.com, jwhan@filewood.snu.ac.kr,
	davem@davemloft.net, sri@us.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120720134014.GD16550@redhat.com>
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

On 07/20/2012 03:40 PM, Michael S. Tsirkin wrote:
>> -	err = init_vqs(vi);
>> > +	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
>> > +		vi->has_cvq = true;
>> > +
> How about we disable multiqueue if there's no cvq?
> Will make logic a bit simpler, won't it?

multiqueues don't really depend on cvq. Does this added complexity really justifies adding an artificial limit?
