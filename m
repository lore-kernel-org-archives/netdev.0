From: ching <lsching17@gmail.com>
Subject: Re: macvlan/macvtap: guest/host cannot communicate
 when network cable is unplugged
Date: Fri, 31 Aug 2012 06:32:37 +0800
Message-ID: <503FEA05.6060202@gmail.com>
References: <503D486B.1030208@gmail.com>
	<CAJSP0QWV_RmEteRMUj4U2B9QRjGMkKL=AG3iyKyqEYiqGftFWg@mail.gmail.com>
	<503F58D0.2010003@gmail.com>
	<CAJSP0QXkHLKpo0kbnPu7L1zH5aL2XCPdmzi7+-xFctU7Pchyqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	qemu-devel@nongnu.org, kaber@trash.net
To: Stefan Hajnoczi <stefanha@gmail.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <CAJSP0QXkHLKpo0kbnPu7L1zH5aL2XCPdmzi7+-xFctU7Pchyqw@mail.gmail.com>
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


>> I also perform an additional test: the guests (macvtap bridge mode) CAN communicate each other no matter network cable is plugged or not.
> Strange.  I thought the original problem was that the macvtap guests
> cannot communicate with each other when the network cable is
> unplugged?
>
> Hopefully someone else can help you, I'm not familiar enough with
> macvlan/macvtap.
>
> Stefan
>

My word may be a little bit confusing, it should be

I also perform an additional test: I created two qemu guests (macvtap bridge mode on eth0), they CAN communicate each other no matter network cable of the host is unplugged or not.

and my problem is specified in the subject already: guest/host cannot communicate when network cable is unplugged


if my configuration seems correct, i may file a kernel bugzilla and seek for their advice.

ching
