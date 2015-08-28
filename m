From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: Add netlink support for
	vlan_protocol attribute
Date: Fri, 28 Aug 2015 08:25:26 -0700
Message-ID: <23C117DA-E4B0-42B5-9445-FCD59BB8B48B@cumulusnetworks.com>
References: <1440655205-14247-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<63AC6A69-F9A1-4A83-8EF7-D897243743B4@cumulusnetworks.com>
	<55E040A9.8040707@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	"David S . Miller" <davem@davemloft.net>
To: Toshiaki Makita <toshiaki.makita1@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <55E040A9.8040707@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


> On Aug 28, 2015, at 4:06 AM, Toshiaki Makita =
<toshiaki.makita1@gmail.com> wrote:
>=20
> On 15/08/28 (=E9=87=91) 0:48, Nikolay Aleksandrov wrote:
>>=20
>>> On Aug 26, 2015, at 11:00 PM, Toshiaki Makita =
<makita.toshiaki@lab.ntt.co.jp> wrote:
>>>=20
>>> This enables bridge vlan_protocol to be configured through netlink.
>>>=20
>>> When CONFIG_BRIDGE_VLAN_FILTERING is disabled, kernel behaves the
>>> same way as this feature is not implemented.
>>>=20
>>> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>>> ---
>>> include/uapi/linux/if_link.h |  1 +
>>> net/bridge/br_netlink.c      | 34 ++++++++++++++++++++++++++++++++++
>>> net/bridge/br_private.h      |  1 +
>>> net/bridge/br_vlan.c         | 35 =
+++++++++++++++++++++--------------
>>> 4 files changed, 57 insertions(+), 14 deletions(-)
>>>=20
>>=20
>> Nice, looks good. I have a similar patch as well and was going to ask =
wouldn=E2=80=99t it be
>> better to make empty stubs which return an error when vlan filtering =
isn=E2=80=99t configured
>> and drop the ifdefs in the netlink handling code ?
>> Similar to how vlan_filtering netlink attribute is handled in commit:
>> a7854037da00 ("bridge: netlink: add support for vlan_filtering =
attribute=E2=80=9D)
>>=20
>> Potential problem would be the return of the protocol, but I think if =
0 is returned that
>> can be handled.
>=20
> This is the exact reason why I didn't implement the stub.
> I wanted to avoid to charge userspace with that special casing 0.
> Also, this is consistent with sysfs implementation, which doesn't =
expose vlan_* entries when CONFIG_BRIDGE_VLAN_PROTOCOL is disabled.
>=20
> Toshiaki Makita

Okay, fair enough.

Thanks,
 Nik=
