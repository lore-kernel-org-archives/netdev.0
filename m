From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: Patch: Fix fec_mpc52xx driver to use net_device_ops
Date: Tue, 31 Mar 2009 10:48:14 -0600
Message-ID: <fa686aa40903310948u43b722c0h1018c09641bd4d68@mail.gmail.com>
References: <ae4f76fd0903310344s2d46edf2l505a1d21a4778d54@mail.gmail.com>
	<20090331074806.432a882a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linuxppc-dev@ozlabs.org, Henk Stegeman <henk.stegeman@gmail.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20090331074806.432a882a@nehalam>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 31, 2009 at 8:48 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Tue, 31 Mar 2009 12:44:15 +0200
>> +static const struct net_device_ops mpc52xx_fec_netdev_ops =3D {
>> + =A0 =A0 =A0 .ndo_open =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D mpc52xx_fec_open,
>> + =A0 =A0 =A0 .ndo_stop =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D mpc52xx_fec_clos=
e,
>> + =A0 =A0 =A0 .ndo_start_xmit =A0 =A0 =A0 =A0 =3D mpc52xx_fec_hard_start=
_xmit,
>> + =A0 =A0 =A0 .ndo_tx_timeout =A0 =A0 =A0 =A0 =3D mpc52xx_fec_tx_timeout,
>> + =A0 =A0 =A0 .ndo_get_stats =A0 =A0 =A0 =A0 =A0=3D mpc52xx_fec_get_stat=
s,
>> + =A0 =A0 =A0 .ndo_set_multicast_list =3D mpc52xx_fec_set_multicast_list,
>> + =A0 =A0 =A0 .ndo_validate_addr =A0 =A0 =A0=3D eth_validate_addr,
>> + =A0 =A0 =A0 .ndo_set_mac_address =A0 =A0=3D mpc52xx_fec_set_mac_addres=
s,
>> + =A0 =A0 =A0 .ndo_do_ioctl =A0 =A0 =A0 =A0 =A0 =3D mpc52xx_fec_ioctl,
>>
> What about change_mtu? Don't you want:
> =A0 =A0 =A0 =A0 =A0.ndo_change_mtu =A0 =A0 =A0 =A0 =3D eth_change_mtu,

Yes, you're right.  fixed.

Thanks,
g.

-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
