From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Bridge & it's MAC address question
Date: Fri, 15 Dec 2006 14:19:08 +0100
Message-ID: <20061215131908.GC11579@xi.wantstofly.org>
References: <200610301527.15018.dim@openvz.org>
	<20061030072837.51177183@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Dmitry Mishin <dim@openvz.org>, netdev@vger.kernel.org, bridge@osdl.org,
   devel@openvz.org
Return-path: <bridge-bounces@lists.osdl.org>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061030072837.51177183@localhost.localdomain>
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

On Mon, Oct 30, 2006 at 07:28:37AM -0800, Stephen Hemminger wrote:

> > Could somebody explain, why bridge uses minimal MAC of the attached dev=
ices?
> > It makes this address instable, variable during bridge life-cycle, whic=
h is =

> > not good for DHCP. For example, I want to attach multiple virtual devic=
es to =

> > one physical. Then, I need to make sure that after each virtual device =

> > addition, bridge addr is not changed and still addr of the physical dev=
ice.  =

> > Why not to use MAC of the first attached device?
> =

> The bridge physical address is the minimum of all the attached devices.
> This is done because the STP standard requires it.  You can reset it
> to be the same as any of the attached devices. This will not cause a
> problem unless using STP.

You can in fact use any MAC address.  The STP standard recommends using
the minimum address, as that is deterministic, and so it doesn't depend
on the order in which you enslave subdevices.
