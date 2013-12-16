From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: NET 3.13.0-rc4 inconsistent lock state
	(&(&sk->sk_dst_lock)->rlock){+.?...},
	at: [<ffffffff818a89e4>] __udp4_lib_rcv+0x9d4/0xa90
Date: Mon, 16 Dec 2013 16:27:32 +0100
Message-ID: <1976498606.20131216162732@eikelenboom.it>
References: <4810128955.20131216160609@eikelenboom.it>
	<1387207372.19078.241.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, netdev@vger.kernel.org,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Eric Dumazet <edumazet@google.com>, Paul Durrant <Paul.Durrant@citrix.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1387207372.19078.241.camel@edumazet-glaptop2.roam.corp.google.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org


Monday, December 16, 2013, 4:22:52 PM, you wrote:

> On Mon, 2013-12-16 at 16:06 +0100, Sander Eikelenboom wrote:
>> On a Xen HVM guest i encountered this lock warning on boot, it looks like it's from the last net pull from Linus.
>> Not sure if it's the Xen-changes or the udp4 ones.

> This is the fourth report of this problem.

> http://patchwork.ozlabs.org/patch/301382/

> Thanks

Sorry for the noise, but probably won't be the last ;-)
