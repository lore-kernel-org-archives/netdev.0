From: "Eble, Dan" <DanE@aiinet.com>
Subject: RE: [PATCH] (3/4) bridge linkstate handling
Date: Thu, 29 Jul 2004 11:11:02 -0400
Sender: bridge-bounces@lists.osdl.org
Message-ID: <C0170D0AF1277849A4B4518034F855DD0CFC3A@aiexchange.ai.aiinet.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============83809984108808=="
Cc: netdev@oss.sgi.com, bridge@osdl.org,
   Stephen Hemminger <shemminger@osdl.org>
Return-path: <bridge-bounces@lists.osdl.org>
Content-class: urn:content-classes:message
To: <hadi@cyberus.ca>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============83809984108808==
Content-class: urn:content-classes:message
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit

> -----Original Message-----
> From: jamal [mailto:hadi@cyberus.ca] 
> 
> On Thu, 2004-07-29 at 09:24, Eble, Dan wrote:
> > Even if STP were implemented in user space, this part 
> should be done in
> > the kernel to make sure that there is no window of time for 
> a packet to
> > be received or transmitted after the link state changes.  
> 
> Your main problem there would be STP convergence time. Transfering the
> packet to user space and reacting should be several factors 
> of magnitude
> faster than it takes STP to converge.
> The STP state should stay in the kernel. Control of it and 
> BPDU handling
> is what i am suggesting to take out.

Is the time it takes STP to converge really the issue in this case?
When a port loses and then regains carrier, it needs to enter the
Blocking state without delay.  If the carrier state change were handled
by a daemon, the bridge driver would have some time to transmit or
receive packets via that port before the daemon could tell it to block
the port, wouldn't it?


--===============83809984108808==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/bridge

--===============83809984108808==--
