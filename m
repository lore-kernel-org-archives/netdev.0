From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost-net: add module alias (v2.1)
Date: Fri, 13 Jan 2012 10:12:45 -0800 (PST)
Message-ID: <20120113.101245.1898604125300586417.davem@davemloft.net>
References: <20120111213038.39213819@nehalam.linuxnetplumber.net>
	<20120112.200701.1473475851890804136.davem@davemloft.net>
	<CAPXgP10uf-5wDxGOP8yhfUcn+18Ga+eZp-Psz_Pxe9PoJZagoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, shemminger@vyatta.com,
	device@lanana.org
To: kay.sievers@vrfy.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAPXgP10uf-5wDxGOP8yhfUcn+18Ga+eZp-Psz_Pxe9PoJZagoA@mail.gmail.com>
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

From: Kay Sievers <kay.sievers@vrfy.org>
Date: Fri, 13 Jan 2012 05:19:05 +0100

> On Fri, Jan 13, 2012 at 05:07, David Miller <davem@davemloft.net> wrote:
>> From: Stephen Hemminger <shemminger@vyatta.com>
>> Date: Wed, 11 Jan 2012 21:30:38 -0800
>>
>>> Subject: vhost-net: add module alias (v2.1)
>>>
>>> By adding some module aliases, programs (or users) won't have to explic=
itly
>>> call modprobe. Vhost-net will always be available if built into the ker=
nel.
>>> It does require assigning a permanent minor number for depmod to work.
>>>
>>> Also:
>>> =A0 - use C99 style initialization.
>>> =A0 - add missing entry in documentation for loop-control
>>>
>>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>
>> ACKs, NACKs? =A0What is happening here?
> =

> In general, static minors are acceptable and very useful to make
> on-demand loading of kernel modules working. They should be used only
> for single-instance devices though, which usually means: One single
> static device name associated with a module.
> =

> That looks all fine here, and for what it's worth:
>   Acked-By: Kay Sievers <kay.sievers@vrfy.org>

Ok, applied, thanks everyone.
