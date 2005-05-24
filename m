From: Jiri Benc <jbenc@suse.cz>
Subject: [0/5] Improvements to the ieee80211 layer
Date: Tue, 24 May 2005 15:07:11 +0200
Message-ID: <20050524150711.01632672@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, jgarzik@pobox.com,
	pavel@suse.cz
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262045AbVEXNHw@vger.kernel.org>
To: NetDev <netdev@oss.sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ieee80211 layer, now present in -mm, lacks many important features
(actually it's just a part of the ipw2100/ipw2200 driver; these cards do
a lot of the processing in the hardware/firmware and thus the layer
currently can not be used for simpler devices).

This is the first series of patches that try to convert it to a generic
IEEE 802.11 layer, usable for most of today's wireless cards.

The long term plan is:
- to implement a complete 802.11 stack in the kernel, making it easy to
  write drivers for simple (cheap) devices
- to implement all of Ad-Hoc, AP and monitor modes in the layer, so it
  will be easy to support them in the drivers
- to integrate Wireless Extensions to unify the kernel-userspace
  interface of all the drivers

This means that drivers for "stupid" (simple, cheap) cards should be
very short and easy to write, whereas drivers for "clever" cards will be
longer (but still shorter than they are now).

We have a couple of cards for testing, and we gradually modify the
drivers for ipw2100 and ipw2200 with the development of the layer. When
the layer is mature enough for the "stupid" cards, we will rewrite the
driver for Atheros-based cards to use this layer. We plan to send all
the patches for these drivers to the netdev list. Of course, we are in
close contact with Pavel Machek, who is pushing the ipw2100 driver
upstream.

Any comments and suggestions are appreciated.


Jiri Benc <jbenc@suse.cz> and Jirka Bohac <jbohac@suse.cz>
SUSE Labs
