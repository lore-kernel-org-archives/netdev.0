From: =?UTF-8?q?Stefan=20Br=C3=BCns?= <stefan.bruens@rwth-aachen.de>
Subject: [PATCH 0/2] Fixes for sierra_net driver
Date: Mon, 6 Feb 2017 21:20:32 +0100
Message-ID: <b739ee7c6000432d9935efebd39acb06@rwthex-w2-b.rwth-ad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        =?UTF-8?q?Stefan=20Br=C3=BCns?= <stefan.bruens@rwth-aachen.de>
To: <linux-usb@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When trying to initiate a dual-stack (ipv4v6) connection, a MC7710, FW
version SWI9200X_03.05.24.00ap answers with an unsupported LSI. Add support
for this LSI.
Also the link_type should be ignored when going idle, otherwise the modem
is stuck in a bad link state.
Tested on MC7710, T-Mobile DE, APN internet.telekom, IPv4v6 PDP type.

Stefan Brüns (2):
  sierra_net: Add support for IPv6 and Dual-Stack Link Sense Indications
  sierra_net: Skip validating irrelevant fields for IDLE LSIs

 drivers/net/usb/sierra_net.c | 92 ++++++++++++++++++++++++++++++--------------
 1 file changed, 63 insertions(+), 29 deletions(-)

-- 
2.11.0
