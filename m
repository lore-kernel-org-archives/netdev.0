From: Peter Bieringer <pb@bieringer.de>
Subject: (usagi-users 02636) IPv6: use_tempaddr: how to set per interface instead for
 default/all?
Date: Wed, 19 Nov 2003 16:40:30 +0100
Message-ID: <14830000.1069256430@worker.muc.bieringer.de>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <usagi-users-admin@linux-ipv6.org>
To: Maillist USAGI-users <usagi-users@linux-ipv6.org>
Content-Disposition: inline
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Hi,

looks there exists a hen/egg problem for the "use_tempaddr" (RFC3041
support).

I cannot set it per interface because:

1) if interface is down, the related key
"net.ipv6.conf.<interface>.use_tempaddr" doesn't exist

2) if interface is up, I can change the key, but nothing happen


-> I have to change "net.ipv6.conf.default.use_tempaddr" *before* the
interface where I want to enable this feature will come up.

This is ok for systems with one interface....but on systems with more than
one interface, this is not a good way, because it's very hard (or
impossible) to code proper scripts.

Is there a interface state possible where the sysctl keys per interface are
already available, but interface is still down?

Thanks for any answer.

BTW: are there more keys existing which are only read/functional on the
trigger edge interface down->up?

        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
