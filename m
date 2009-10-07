From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pasemi_mac: ethtool get settings fix
Date: Wed, 07 Oct 2009 03:43:09 -0700 (PDT)
Message-ID: <20091007.034309.111268582.davem@davemloft.net>
References: <4AC9ED9B.5040400@ru.mvista.com>
	<20091005132756.GA11704@ru.mvista.com>
	<20091006161054.GB29195@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, jgarzik@pobox.com, netdev@vger.kernel.org
To: olof@lixom.net
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20091006161054.GB29195@lixom.net>
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

From: Olof Johansson <olof@lixom.net>
Date: Tue, 6 Oct 2009 11:10:54 -0500

> Weird, I see my address in the to: line but I never got a copy in my inbox.
> 
> On Mon, Oct 05, 2009 at 05:27:56PM +0400, Valentine Barshak wrote:
>> Not all pasemi mac interfaces can have a phy attached.
>> For example, XAUI has no phy and phydev is NULL for it.
>> In this case ethtool get settings causes kernel crash.
>> Fix it by returning -EOPNOTSUPP if there's no PHY attached.
>> 
>> Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
> 
> Acked-by: Olof Johansson <olof@lixom.net>

Applied to net-2.6, thanks!
