From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost-net: add module alias (v2.1)
Date: Mon, 16 Jan 2012 18:06:47 -0500 (EST)
Message-ID: <20120116.180647.1716624961347284814.davem@davemloft.net>
References: <20120115124236.GA31012@redhat.com>
	<20120116122645.2257b40b@bob.linux.org.uk>
	<20120116075236.110cc4b4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	kay.sievers@vrfy.org, virtualization@lists.linux-foundation.org,
	device@lanana.org, alan@linux.intel.com
To: shemminger@vyatta.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120116075236.110cc4b4@nehalam.linuxnetplumber.net>
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

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 16 Jan 2012 07:52:36 -0800

> On Mon, 16 Jan 2012 12:26:45 +0000
> Alan Cox <alan@linux.intel.com> wrote:
> 
>> > > ACKs, NACKs?  What is happening here?
>> > 
>> > I would like an Ack from Alan Cox who switched vhost-net
>> > to a dynamic minor in the first place, in commit
>> > 79907d89c397b8bc2e05b347ec94e928ea919d33.
>> 
>> Sorry device@lanana.org isn't yet back from the kernel hack incident.
>> 
>> I don't read netdev so someone needs to summarise the issue and send me
>> a copy of the patch to look at.
>> 
>> Alan
> 
> Subject: vhost-net: add module alias (v2.1)
> 
> By adding some module aliases, programs (or users) won't have to explicitly
> call modprobe. Vhost-net will always be available if built into the kernel.
> It does require assigning a permanent minor number for depmod to work.
> 
> Also:
>   - use C99 style initialization.
>   - add missing entry in documentation for loop-control
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I already applied your first patch, so you need to give me something
relative to apply on top of your original one.

And it also shows that you're really not generating these patches
against current 'net', otherwise you'd have noticed your other patch
already there.
