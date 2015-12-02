From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH 0/2] mvneta: implement ethtool autonegotiation control
Date: Wed, 2 Dec 2015 20:32:24 +0300
Message-ID: <565F2B28.4080501@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These 2 patches add an ability to control the
autonegotiation via ethtool. For example:

ethtool -s eth0 autoneg off
ethtool -s eth0 autoneg on

This is needed if you want to connect the mvneta's MII
to different switches or PHYs: the ones the do support
the in-band status, and the ones that do not.
