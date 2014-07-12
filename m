From: Christoph Schulz <develop@kristov.de>
Subject: [PATCH 0/1]   net: pppoe: use correct channel MTU when using Multilink
 PPP
Date: Sun, 13 Jul 2014 00:53:12 +0200
Message-ID: <53C1BC58.3030803@kristov.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-ppp@vger.kernel.org, mostrows@gmail.com
To: netdev@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

when computing the PPPoE channel MTU, we have to subtract two bytes, as
ppp_mp_explode() expects the channel MTU to exclude the size of the PPP
protocol field, which is correct according to RFC 1661.

See patch 1 for details.

Best regards,

Christoph

Christoph Schulz (1):
  net: pppoe: use correct channel MTU when using Multilink PPP

 drivers/net/ppp/pppoe.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
