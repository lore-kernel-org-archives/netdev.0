From: Eric Leblond <eric@regit.org>
Subject: [PATCH 0/1] oops in af_packet fanout mode
Date: Tue,  6 Nov 2012 11:24:40 +0100
Message-ID: <1352197481-16782-1-git-send-email-eric@regit.org>
Cc: stable@vger.kernel.org
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ks28632.kimsufi.com ([91.121.96.152]:48869 "EHLO
	ks28632.kimsufi.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277Ab2KFLDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 06:03:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Due to a NULL dereference, the following patch is causing oops
in normal trafic condition:

commit c0de08d04215031d68fa13af36f347a6cfa252ca
Author: Eric Leblond <eric@regit.org>
Date:   Thu Aug 16 22:02:58 2012 +0000

    af_packet: don't emit packet on orig fanout group

This patch was a feature fix and has reached most stable
branches. The following patch fixes the issue and should be
applied to branch containing the previous patch.

BR,
--
Eric Leblond <eric@regit.org>
