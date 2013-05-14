From: Nicholas Thomas <nick@bytemark.co.uk>
Subject: Re: tap devices not receiving packets from a bridge
Date: Tue, 14 May 2013 15:49:09 +0100
Message-ID: <1368542949.15129.354.camel@eboracum.office.bytemark.co.uk>
References: <50AE36E0.8000307@dlhnet.de>
	<20121123070211.GC22787@stefanha-thinkpad.hitronhub.home>
	<E85C6011-548D-4507-A776-1028DD3E3515@dlhnet.de>
	<20121123110146.GC7051@redhat.com> <50FE5607.9020405@dlhnet.de>
	<20130123100312.GA8108@redhat.com>  <5119E9DC.3000505@dlhnet.de>
	<1368541284.15129.317.camel@eboracum.office.bytemark.co.uk>
	<519249F6.3000900@dlhnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stefan Hajnoczi <stefanha@gmail.com>, netdev@vger.kernel.org,
	qemu-devel@nongnu.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Peter Lieven <pl@dlhnet.de>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <519249F6.3000900@dlhnet.de>
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

Hi,

On Tue, 2013-05-14 at 16:28 +0200, Peter Lieven wrote:

> Please check the tunnel mode in sysfs after your VM is started. It is likely
> that qemu overwrites the settings you made in the ruby script.
> 
> Please check if the patch
> 
> tap: set IFF_ONE_QUEUE per default
> 
> is in your qemu 1.4.1 version.

That didn't even cross my mind!

/sys/devices/virtual/net/t100/tun_flags is 0x5002 - so it looks like
IFF_ONE_QUEUE was indeed unset by qemu (which is lacking the patch). It
surprises me, but that's probably my fault, rather than qemu's.

Sorry for the noise, and thanks for the quick response :)

/Nick
