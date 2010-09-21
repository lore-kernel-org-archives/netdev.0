From: LEROY Christophe <christophe.leroy@c-s.fr>
Subject: Dual ethernet attachment with single FEC
Date: Tue, 21 Sep 2010 09:30:10 +0200
Message-ID: <4C985F02.7060403@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
To: LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Hello,

I have a board with 2 PHYs attached to one FEC ethernet controler on 
powerpc.
I want to implement some kind of main-standby attachment to LAN by 
setting the ISOLATE bit on one on the two PHYs then monitoring the link 
status and switch to the other PHY when the link status goes down.

I see this behaviour is implemented in the sis900 driver, but it doesn't 
use the standard PHY layer as the Freescale FEC driver does.

What would be the most proper way to implement this functionality ?
* Modify FEC driver to manage that ?
* Implement a virtual PHY driver that would manage that ?
* Other solution ?

Best regards
C. Leroy
