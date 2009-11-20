From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: move tc variable to CONFIG_IXGBE_DCB
Date: Fri, 20 Nov 2009 11:16:54 -0800
Message-ID: <9929d2390911201116l562291cbh8e6a557b64fa7ef0@mail.gmail.com>
References: <1258725747.3562.5.camel@ht.satnam>
	 <9929d2390911200624mf352c28u55a8b2aee8b52fa3@mail.gmail.com>
	 <20091120.111355.141716974.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jaswinder@kernel.org, yi.zou@intel.com,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755329AbZKTTQt@vger.kernel.org>
In-Reply-To: <20091120.111355.141716974.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 20, 2009 at 11:13, David Miller <davem@davemloft.net> wrote=
:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri, 20 Nov 2009 06:24:21 -0800
>
>> On Fri, Nov 20, 2009 at 06:02, Jaswinder Singh Rajput
>> <jaswinder@kernel.org> wrote:
>>>
>>> tc is required by CONFIG_IXGBE_DCB.
>>> This also fixes compilation warning:
>>>
>>> =C2=A0drivers/net/ixgbe/ixgbe_main.c: In function =E2=80=98ixgbe_tx=
_is_paused=E2=80=99:
>>> =C2=A0drivers/net/ixgbe/ixgbe_main.c:245: warning: unused variable =
=E2=80=98tc=E2=80=99
>>>
>>> Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
> =C2=A0...
>> I just submitted a patch to fix this. =C2=A0So NAK.
>
> But his is much cleaner that your's, less ifdefs. =C2=A0I think we
> should therefore use Jasdinder's version.
>
>

:) That is fine.  The end result is the same.

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=20
Cheers,
Jeff
