From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
Subject: crappy/good gigabit chipsets?
Date: Sat, 27 Nov 2004 07:17:57 +0100
Message-ID: <41A81C15.5080905@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm trying to build a gigabit ethernet bridge with Linux 2.6 and
commodity hardware. The bridge should be able to filter traffic
(probably with ebtables), which will mostly be operations like
"drop traffic from this host", "drop traffic to this port", to
stop infected windows machines generating traffic until they are
reformatted with Linux.
The traffic source is a 100 MBit switched network with 2500 PCs
(1 GBit Uplink) and the usual frame sizes on a switched 100 MBit
network and the sink is a machine doing masquerading of the
internal machines to the outside world.

IIRC, TSO, hardware checksumming etc. are abolutely unneeded for
this type of operation, but a fast transfer of the packets to/
from memory is essential. Maybe I'm crazy to assume a current
machine with classic 32 bit PCI bus can handle such a load, but
since Linux performs stellar with a bunch of 100 MBit cards at
the same time, I see at least some hope.

Which gigabit chipsets do classic data transfer fast enough to
get a recommendation from the experts?

Which gigabit drivers are stable und well-written enough to
sustain fully loaded interfaces without breaking down?

Which chipsets should be avoided?

Thank you very much for your time.

Regards,
Carl-Daniel
-- 
http://www.hailfinger.org/
