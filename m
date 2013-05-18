From: Tony Prisk <linux@prisktech.co.nz>
Subject: Re: [PATCHv6 0/3] Add support for velocity network driver on platform
 devices
Date: Sat, 18 May 2013 14:22:57 +1200
Message-ID: <5196E601.10202@prisktech.co.nz>
References: <1368768078-16121-1-git-send-email-linux@prisktech.co.nz> <20130517.141938.2120801813213703422.davem@davemloft.net> <20130517.173644.1877140985770026320.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	romieu@fr.zoreil.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130517.173644.1877140985770026320.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/05/13 12:36, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 17 May 2013 14:19:38 -0700 (PDT)
>
>> Series applied, thanks.
> I'm reverting this, you're not using the correct types for the PM
> functions you're hooking up.
>
> drivers/net/ethernet/via/via-velocity.c:3238:8: warning: initializati=
on from incompatible pointer type [enabled by default]
> drivers/net/ethernet/via/via-velocity.c:3238:8: warning: (near initia=
lization for =A1velocity_pm_ops.suspend=A2) [enabled by default]
> drivers/net/ethernet/via/via-velocity.c:3238:8: warning: initializati=
on from incompatible pointer type [enabled by default]
> drivers/net/ethernet/via/via-velocity.c:3238:8: warning: (near initia=
lization for =A1velocity_pm_ops.freeze=A2) [enabled by default]
> drivers/net/ethernet/via/via-velocity.c:3238:8: warning: initializati=
on from incompatible pointer type [enabled by default]
> drivers/net/ethernet/via/via-velocity.c:3238:8: warning: (near initia=
lization for =A1velocity_pm_ops.poweroff=A2) [enabled by default]
Argh.. sorry Dave.
I forgot to merge the fixup for this before sending. Fixed version to=20
follow.

Regards
Tony P
