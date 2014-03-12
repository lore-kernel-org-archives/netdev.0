From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 1/2] bridge: multicast: add sanity check for
 general query destination
Date: Tue, 11 Mar 2014 23:23:25 -0400 (EDT)
Message-ID: <20140311.232325.2172162494177450404.davem@davemloft.net>
References: <1394486725-4992-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, fwestpha@redhat.com,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	stephen@networkplumber.org, jstancek@redhat.com
To: linus.luessing@web.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1394486725-4992-1-git-send-email-linus.luessing@web.de>
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
Date: Mon, 10 Mar 2014 22:25:24 +0100

> General IGMP and MLD queries are supposed to have the multicast
> link-local all-nodes address as their destination according to RFC223=
6
> section 9, RFC3376 section 4.1.12/9.1, RFC2710 section 8 and RFC3810
> section 5.1.15.
> =

> Without this check, such malformed IGMP/MLD queries can result in a
> denial of service: The queries are ignored by most IGMP/MLD listeners=

> therefore they will not respond with an IGMP/MLD report. However,
> without this patch these malformed MLD queries would enable the
> snooping part in the bridge code, potentially shutting down the
> according ports towards these hosts for multicast traffic as the
> bridge did not learn about these listeners.
> =

> Reported-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Linus L=FCssing <linus.luessing@web.de>

Applied.
