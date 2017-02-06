From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: Fix IPv6 packet loss in scenarios
 involving roaming + snooping switches
Date: Mon, 06 Feb 2017 11:43:29 -0500 (EST)
Message-ID: <20170206.114329.1196570425826508517.davem@davemloft.net>
References: <20170203071103.25976-1-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	linux-wireless@vger.kernel.org, jmorris@namei.org,
	linux-kernel@vger.kernel.org, monis@voltaire.com,
	kuznet@ms2.inr.ac.ru, kaber@trash.net
To: linus.luessing@c0d3.blue
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170203071103.25976-1-linus.luessing@c0d3.blue>
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

From: Linus L=FCssing <linus.luessing@c0d3.blue>
Date: Fri,  3 Feb 2017 08:11:03 +0100

> When for instance a mobile Linux device roams from one access point t=
o
> another with both APs sharing the same broadcast domain and a
> multicast snooping switch in between:
> =

> 1)    (c) <~~~> (AP1) <--[SSW]--> (AP2)
> =

> 2)              (AP1) <--[SSW]--> (AP2) <~~~> (c)
> =

> Then currently IPv6 multicast packets will get lost for (c) until an
> MLD Querier sends its next query message. The packet loss occurs
> because upon roaming the Linux host so far stayed silent regarding
> MLD and the snooping switch will therefore be unaware of the
> multicast topology change for a while.
> =

> This patch fixes this by always resending MLD reports when an interfa=
ce
> change happens, for instance from NO-CARRIER to CARRIER state.
> =

> Signed-off-by: Linus L=FCssing <linus.luessing@c0d3.blue>

Looks good to me, applied, thanks.
