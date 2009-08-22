From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: VLANs and bridge
Date: Sat, 22 Aug 2009 15:49:11 +0200
Message-ID: <OFC5BA9A4A.DCCE8D0D-ONC125761A.004A7620-C125761A.004BEA17@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


This is probably no news to experienced bridge and VLAN users but I just learned the
hard way that Shared VLAN learning(SVL) isn't supported
by the linux bridge making it impossible to support configurations described in B.1.3
Basically the bride needs to be made VLAN aware and the VLAN code needs to be adopted
to allow this.

I figured I should mention it in case it is just an oversight. It does not look like a simple
job though.

 Jocke
