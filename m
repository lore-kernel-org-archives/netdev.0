From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Can linux kernel bridge forward 802.1q tagged vlan packets?
Date: Thu, 22 Aug 2013 22:44:53 +0200
Message-ID: <20130822224453.ca93782f.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bridge@lists.linux-foundation.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
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

Hello all,

first it seemed a trivial question to me, but since I could not find anybody
being neither able to answer this question nor giving a short config example
I'd like to ask here, maybe this is the right place.
My general idea is to bridge tagged vlan packets from a physical interface
(intel) to a virtual interface (virtio in qemu) and not losing the tags, so
the qemu guest can use vconfig and friends to get some vlan interfaces.
Is this possible and are there any additional steps necessary besides the
usual bridge configuration?
What bothers me especially is the vlan filtering done by nics which can
prevent to even receive the packets from the LAN.
And on the other side of course can the bridge code forward packets including
tags so that virtio is able to handle them?

-- 
Regards,
Stephan
