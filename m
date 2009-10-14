From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH v2] net/fec_mpc52xx: Fix kernel panic on FEC error
Date: Wed, 14 Oct 2009 13:32:54 -0600
Message-ID: <fa686aa40910141232nab95d4al13016d4dc4fbc6cf@mail.gmail.com>
References: <20091014174224.29221.18830.stgit@angua>
	<4AD62247.4020102@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: John Bonesio <bones@secretlab.ca>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, davem@davemloft.net
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <4AD62247.4020102@grandegger.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 14, 2009 at 1:11 PM, Wolfgang Grandegger <wg@grandegger.com> wr=
ote:
> Grant Likely wrote:
>> From: John Bonesio <bones@secretlab.ca>
>>
>> The MDIO bus cannot be accessed at interrupt context, but on an FEC
>> error, the fec_mpc52xx driver reset function also tries to reset the
>> PHY. =A0Since the error is detected at IRQ context, and the PHY functions
>> try to sleep, the kernel ends up panicking.
>>
>> Resetting the PHY on an FEC error isn't even necessary. =A0This patch
>> solves the problem by removing the PHY reset entirely.
>
> There is also no need to free and re-allocate the RX buffers in
> mpc52xx_fec_reset().

Write and test a patch for me!  :-)

g.

-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
