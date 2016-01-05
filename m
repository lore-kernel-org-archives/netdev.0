From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv2 net-next 0/4] MTU changes and other fixes
Date: Tue,  5 Jan 2016 11:57:27 +0000
Message-ID: <1451995051-21920-1-git-send-email-jakub.kicinski@netronome.com>
Cc: simon.horman@netronome.com, rolf.neugebauer@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37336 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081AbcAEL5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 06:57:37 -0500
Received: by mail-wm0-f51.google.com with SMTP id f206so25451227wmf.0
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 03:57:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Four small fixes around RX buffer sizing.  First one makes sure
we return an error if .ndo_change_mtu() fails.  Second one corrects
the length used for unmapping DMA buffers when MTU is changed,
third makes sure buffers are big enough to meet FW's expectations.
Last change corrects packet length validation on RX.

v2:
 - add first patch (return error on fail).


Jakub Kicinski (4):
  nfp: return error if MTU change fails
  nfp: free buffers before changing MTU
  nfp: correct RX buffer length calculation
  nfp: fix RX buffer length validation

 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 42 ++++++++++------------
 1 file changed, 18 insertions(+), 24 deletions(-)

-- 
1.9.1
