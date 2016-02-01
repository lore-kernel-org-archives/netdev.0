From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: bonding (IEEE 802.3ad) not working with qemu/virtio
Date: Mon, 1 Feb 2016 10:49:54 -0800
Message-ID: <56AFA8D2.50500@hpe.com>
References: <56ABDA3D.8040100@cumulusnetworks.com> <28285.1454103900@famine>
	<56ABDE2A.7010301@cumulusnetworks.com>
	<20160129.225924.1343743091073159760.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, mst@redhat.com, gospo@cumulusnetworks.com,
	virtualization@lists.linux-foundation.org,
	bjornar.ness@gmail.com, vfalico@gmail.com,
	netdev@vger.kernel.org, jay.vosburgh@canonical.com
To: David Miller <davem@davemloft.net>, nikolay@cumulusnetworks.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20160129.225924.1343743091073159760.davem@davemloft.net>
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

On 01/29/2016 10:59 PM, David Miller wrote:
> There should be a default speed/duplex setting for such devices as well.
> We can pick one that will be use universally for these kinds of devices.

There is at least one monitoring tool - collectl - which gets a trifle 
upset when the actual speed through an interface is significantly 
greater than the reported link speed.  I have to wonder how unique it is 
in that regard.

Doesn't mean there can't be a default, but does suggest it should be 
rather high.

rick jones
