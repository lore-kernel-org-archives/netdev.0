From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4180] New: masquarade and source ip
Date: Mon, 7 Feb 2005 11:18:22 -0800
Message-ID: <20050207111822.65038881.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: spied@yandex.ru
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Mon, 7 Feb 2005 10:16:56 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4180] New: masquarade and source ip


http://bugme.osdl.org/show_bug.cgi?id=4180

           Summary: masquarade and source ip
    Kernel Version: 2.6.10
            Status: NEW
          Severity: normal
             Owner: laforge@gnumonks.org
         Submitter: spied@yandex.ru


i try next on router (eth0 - inernet, eth1 - localnet):

ip addr add eth0 1.2.3.4
ip addr add eth0 2.3.4.5

ip route add default via 2.3.4.6 src 2.3.4.5

iptables  -t nat -A POSTROUTING -s 10.0.0.0/8 -d ! 10.0.0.0/8 -j MASQUERADE

if i do ping www.google.com from router source ip is 2.3.4.5, but if i do ping
from local network source ip is 1.2.3.4 (i think it's wrong)

with older kernel source ip is always set to 2.3.4.5

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
