From: Alpt <alpt@freaknet.org>
Subject: Re: [PATCH] bridge hub_enabled option
Date: Wed, 30 Mar 2005 13:14:24 +0200
Message-ID: <20050330111424.GA16289@nihil>
References: <20050326224030.GA31822@darkalpt>
	<20050329142719.4bd7cb57@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============21458369763702345=="
Cc: netdev@oss.sgi.com, bridge@lists.osdl.org
Return-path: <bridge-bounces@lists.osdl.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050329142719.4bd7cb57@dxpl.pdx.osdl.net>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Sender: bridge-bounces@lists.osdl.org
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============21458369763702345==
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Mar 29, 2005 at 02:27:19PM -0800, Stephen Hemminger wrote  :
~> On Sat, 26 Mar 2005 23:40:30 +0100
~> Alpt <alpt@freaknet.org> wrote:
~> > Bridge hub_enabled patch:
~> > this patch adds the hub_enabled option for bridge.
~> > 
~> > By default the hub_enabled flag is set to 1. In this case nothing changes, the
~> > bridge, as usually, acts as a hub and flood_forward the input pkts to all its
~> > ports. When hun_enabled is set to 0, the bridge stops to flood_forward the input
~> > traffic and takes only the pkts sent to it.
~> > Disabling the hub option is useful to join multiple interfaces into a unique virtual
~> > one, thus becomes possible to have easily an ad-hoc network topology using multiple
~> > interfaces.
~> 
~> Could you give a better example of how this would be useful?
~> Why would you not want A to talk to C? 

For example to test a routing protocol.

~> Why not enforce the policy with ebtables?

To not rely to the ip addresses but just having x interfaces merged and to have
a cleaner and simpler way to do it.

Regards
-- 
:wq!
"I don't know nothing" The One Who reached the Thinking Matter   '.'

[ Alpt --- Freaknet Medialab ]
[ GPG Key ID 441CF0EE ]
[ Key fingerprint = 8B02 26E8 831A 7BB9 81A9  5277 BFF8 037E 441C F0EE ]

--===============21458369763702345==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/bridge

--===============21458369763702345==--
