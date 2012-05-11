From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: of/phy: fix build error when phylib is built as a
 module
Date: Fri, 11 May 2012 18:03:28 -0400 (EDT)
Message-ID: <20120511.180328.1412689186292656882.davem@davemloft.net>
References: <20120510.224352.2149006669429730060.davem@davemloft.net>
 <1336751221-19127-1-git-send-email-bjorn@mork.no>
 <4FAD532E.401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 paul.gortmaker@windriver.com, rdunlap@xenotime.net, linux-next@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, bjorn@mork.no
To: ddaney.cavm@gmail.com
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <4FAD532E.401@gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney.cavm@gmail.com>
Date: Fri, 11 May 2012 10:58:06 -0700

> On 05/11/2012 08:47 AM, Bj=F8rn Mork wrote:
>> CONFIG_OF_MDIO is tristate and will be m if PHYLIB is m.  Use
>> IS_ENABLED macro to prevent build error:
>>
>>   ERROR: "of_mdio_find_bus" [drivers/net/phy/mdio-mux.ko] undefined!
>>
>> Reported-by: Randy Dunlap<rdunlap@xenotime.net>
>> Cc: David Daney<david.daney@cavium.com>
>> Signed-off-by: Bj=F8rn Mork<bjorn@mork.no>
> =

> I was able to reproduce the failure, and this patch both fixes it and
> seems correct, so...
> =

> Acked-by: David Daney<david.daney@cavium.com>

Applied.
