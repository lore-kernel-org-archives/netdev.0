From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 0/11 v3] tlan: Link handling improvements and Olicom fixes
Date: Mon, 30 Jun 2014 18:38:26 +0200
Message-ID: <1404146317-3094-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch series improves link handling in tlan driver, allowing the
cable to be (un)plugged anytime and NetworkManager to work properly.

Also there are some bugfixes related to Olicom OC-2326 card.

---
 tlan.c |  224 ++++++++++++++++++++++++++++++++++++++---------------------------
 tlan.h |    5 -
 2 files changed, 134 insertions(+), 95 deletions(-)


-- 
Ondrej Zary
