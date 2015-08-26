From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] bridge: vlan: allow to suppress
	local mac install for all vlans
Date: Wed, 26 Aug 2015 04:33:43 -0700
Message-ID: <AB16F445-DCA7-437E-B6E1-B70FDC63E55A@cumulusnetworks.com>
References: <1440549295-3979-1-git-send-email-razor@blackwall.org>
	<20150825.194222.390859854071446877.davem@davemloft.net>
	<E065D3DC-6CBC-4625-8800-5133E21C5483@cumulusnetworks.com>
	<20150825.230641.773630246486190390.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: vyasevic@redhat.com, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, wkok@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20150825.230641.773630246486190390.davem@davemloft.net>
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


> On Aug 25, 2015, at 11:06 PM, David Miller <davem@davemloft.net> =
wrote:
>=20
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Date: Tue, 25 Aug 2015 22:28:16 -0700
>=20
>> Certainly, that should be done and I will look into it, but the
>> essence of this patch is a bit different. The problem here is not
>> the size of the fdb entries, it=E2=80=99s more the number of them - =
having
>> 96000 entries (even if they were 1 byte ones) is just way too much
>> especially when the fdb hash size is small and static. We could work
>> on making it dynamic though, but still these type of local entries
>> per vlan per port can easily be avoided with this option.
>=20
> 96000 bits can be stored in 12k.  Get where I'm going with this?
>=20
> Look at the problem sideways.

Oh okay, I misunderstood your previous comment. I=E2=80=99ll look into =
that.

Thanks,
 Nik=
