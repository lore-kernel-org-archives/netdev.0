From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bridge: flush forwarding table when device
	carrier off
Date: Thu, 12 Oct 2006 16:10:44 -0400
Message-ID: <20061012201043.GA29253@gospo.rdu.redhat.com>
References: <20061012112431.0550b252@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, bridge@osdl.org,
   "David S. Miller" <davem@davemloft.net>
Return-path: <bridge-bounces@lists.osdl.org>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061012112431.0550b252@dxpl.pdx.osdl.net>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Sender: bridge-bounces@lists.osdl.org
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 12, 2006 at 11:24:31AM -0700, Stephen Hemminger wrote:
> Flush the forwarding table when carrier is lost. This helps for
> availability because we don't want to forward to a downed device and
> new packets may come in on other links.
> =

> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> =


Stephen,

This is an excellent idea and all looks good except this check

+			if (f->is_static & !do_all)
+				continue;

should be this: =


+			if (f->is_static && !do_all)
+				continue;

I'll ACK a repost with that change.

-andy
