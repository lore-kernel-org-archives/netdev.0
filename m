From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 0/9] tlan: Link handling improvements and Olicom fixes
Date: Tue, 27 May 2014 23:38:38 +0200
Message-ID: <1401226727-5508-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series improves link handling in tlan driver, allowing the
cable to be (un)plugged anytime and NetworkManager to work properly.

Also there are some bugfixes related to Olicom OC-2326 card.
But one bug remains: packet loss at 10 Mbps under load. As wireshark shows,
the card does not transmit some of the packets. Everything seems to be fine
from driver's view - can't figure out where the problem is.

-- 
Ondrej Zary
