From: Peter Lieven <pl@dlhnet.de>
Subject: tap devices not receiving packets from a bridge
Date: Thu, 22 Nov 2012 15:29:52 +0100
Message-ID: <50AE36E0.8000307@dlhnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>,
 netdev@vger.kernel.org
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
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

is anyone aware of a problem with the linux network bridge that in very rare circumstances stops
a bridge from sending pakets to a tap device?

My problem occurs in conjunction with vanilla qemu-kvm-1.2.0 and Ubuntu Kernel 3.2.0-34.53
which is based on Linux 3.2.33.

I was not yet able to reproduce the issue, it happens in really rare cases. The symptom is that
the tap does not have any TX packets. RX is working fine. I see the packets coming in at
the physical interface on the host, but they are not forwarded to the tap interface.
The bridge itself has learnt the mac address of the vServer that is connected to the tap interface.
It does not help to toggle the bridge link status,  the tap interface status or the interface in the vServer.
It seems that problem occurs if a tap interface that has previously been used, but set to nonpersistent
is set persistent again and then is by chance assigned to the same vServer (=same mac address on same
bridge) again. Unfortunately it seems not to be reproducible.

Maybe this sounds familiar to someone?

Thank you,
Peter
