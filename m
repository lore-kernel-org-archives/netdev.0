From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [RFC PATCH 0/6] cdc_ncm: some basic refactoring
Date: Mon, 29 Dec 2014 11:09:42 +0100
Message-ID: <1419847788-25610-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:32810 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbaL2KJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 05:09:28 -0500
Received: by mail-wi0-f179.google.com with SMTP id ex7so21597625wid.0
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 02:09:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is some work I did to move in the direction of refactoring the cdc_ncm
module, to allow for future further changes.
This is work in progress (WIP): and I know some changes are controversial. In
particular, the modification you can see related to cdc_ncm.h header file is
useless at this point. But actually it can be useful for learning from your
opinions: is this the right thing to do?
Thank in advance to anyone reviewing this code.
The final objective would be to have the driver accumulate frames as it does
now, but in a skb queue (sk_buff_head), and then generating the NCM frame
itself only when needed (queue full / flueshed).
I need assistance / help: the logic seems hard to follow for me (is it me or
is it little bit convoluted?).
Thank you for any help, waiting for your comments.
Note: please CC me as I am not subscribed to this list.


Enrico Mioso (6):
  cdc_ncm: factor out skb allocation and finalizzing
  cdc_ncm: be more precise in comments for cdc_ncm_prepare_skb_ncm16
  cdc_ncm: add needed members to cdc_ncm_ctx for refactoring
  cdc_ncm: update specs URL
  cdc_ncm: fix typo
  cdc_ncm: factor out NDP preparation and frame linking

 drivers/net/usb/cdc_ncm.c   | 74 ++++++++++++++++++++++++++++++++-------------
 include/linux/usb/cdc_ncm.h |  1 +
 2 files changed, 54 insertions(+), 21 deletions(-)

-- 
2.2.1
