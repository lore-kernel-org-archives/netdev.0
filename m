From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: multicast: add sanity check for query
 source addresses
Date: Wed, 05 Mar 2014 20:46:01 -0500 (EST)
Message-ID: <20140305.204601.621108199680054921.davem@davemloft.net>
References: <1393901855-18231-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, fwestpha@redhat.com,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	stephen@networkplumber.org, jstancek@redhat.com
To: linus.luessing@web.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1393901855-18231-1-git-send-email-linus.luessing@web.de>
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

From: Linus L=FCssing <linus.luessing@web.de>
Date: Tue,  4 Mar 2014 03:57:35 +0100

> MLD queries are supposed to have an IPv6 link-local source address
> according to RFC2710, section 4 and RFC3810, section 5.1.14. This pat=
ch
> adds a sanity check to ignore such broken MLD queries.
> =

> Without this check, such malformed MLD queries can result in a
> denial of service: The queries are ignored by any MLD listener
> therefore they will not respond with an MLD report. However,
> without this patch these malformed MLD queries would enable the
> snooping part in the bridge code, potentially shutting down the
> according ports towards these hosts for multicast traffic as the
> bridge did not learn about these listeners.
> =

> Reported-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Linus L=FCssing <linus.luessing@web.de>

Applied.
