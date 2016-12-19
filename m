From: Madalin-Cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [PATCH net v2 2/5] powerpc: remove fsl,fman from of_device_ids[]
Date: Mon, 19 Dec 2016 16:07:45 +0000
Message-ID: <AM4PR04MB16044EBA36B62CBA1CEB5C96EC910@AM4PR04MB1604.eurprd04.prod.outlook.com>
References: <1482139343-8975-1-git-send-email-madalin.bucur@nxp.com>
 <1482139343-8975-3-git-send-email-madalin.bucur@nxp.com>
 <20161219.103712.1578523196484939315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Scott Wood <scott.wood@nxp.com>
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20161219.103712.1578523196484939315.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, December 19, 2016 5:37 PM
>=20
> From: Madalin Bucur <madalin.bucur@nxp.com>
> Date: Mon, 19 Dec 2016 11:22:20 +0200
>=20
> > The fsl/fman drivers will use of_platform_populate() on all
> > supported platforms.
> >
> > Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
>=20
> It seems that this creates a failure point between patches #2 and
> #3.  If the cases handled by this "fsl,fman" entry are only afterwards
> covered by the of_platform_populate() code added in patch #3 then you
> cannot split these two changes up like this.
>=20
> The two changes must be done at the same time, otherwise probing will
> fail for some people between patches #2 and #3.

You are right, that will happen. I was not convinced these need to be
merged due to the different places they touch. I'll send a v3.
