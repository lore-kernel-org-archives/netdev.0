From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] macvtap: Fix macvtap_get_queue to use rxhash first
Date: Mon, 28 Nov 2011 09:42:00 -0800
Message-ID: <20111128094200.2cb823a0@nehalam.linuxnetplumber.net>
References: <20111124081714.26635.68141.sendpatchset@krkumar2.in.ibm.com>
	<20111124095902.GD14491@redhat.com> <4ECE18D5.3060605@redhat.com>
	<20111124103449.GA16031@redhat.com> <4ECE3F0D.3090908@redhat.com>
	<20111124161430.GC26770@redhat.com>
	<OF86B15006.7F4BE3FB-ON65257953.00104C3E-65257953.0010EFCA@in.ibm.com>
	<4ECF09D5.4010700@redhat.com>
	<OF835A6FF5.7D752AD1-ON65257953.0016350C-65257953.00169AF4@in.ibm.com>
	<4ED30D2B.10907@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, arnd@arndb.de, "Michael S.
	Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <4ED30D2B.10907@redhat.com>
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

On Mon, 28 Nov 2011 12:25:15 +0800
Jason Wang <jasowang@redhat.com> wrote:

> I'm using ixgbe for testing also, for host, its driver seems provide irq 
> affinity hint, so no binding or irqbalance is needed.

The hint is for irqbalance to use. You need to still do manual
affinity or use irqbalance.
