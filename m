From: Erwan Velu <erwanaliasr1@gmail.com>
Subject: Opportunity to backport pch_gbe patches to stable 3.2.x
Date: Wed, 19 Sep 2012 20:41:38 +0200
Message-ID: <505A11E2.8000403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:52482 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756812Ab2ISSlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 14:41:44 -0400
Received: by eekc1 with SMTP id c1so574202eek.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 11:41:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

I'm using on a daily use and in production 3.2.x kernels (.29 currently) on a Kontron Nano-etx board that features the pch_gbe network driver.

I've been experiencing lots of troubles on this kernel series but since I've backported the following commits back to my 3.2.x, it works far better.

So from the history of next the following commits apply perfectly and runs very well.

I do think that other users of pch_gbe will appreciate this.

1a0bdadb4e36abac63b0a9787f372aac30c11a9e
5481c8cd83b4cb0f9f0746e1f477ac231e7eedb6
eefc48b078e1c74c701e8b44a56717418e9cd2bb
93c8acb599b72ca7da42e36d7971a28dce273665
32127a0a0a35706c18df11cd7ad69e96214b3c68
d89bdff152acc0c1e1c8093832547a553b69b45c
62ecc37986414ff98ba863f8f4b8c3fa9c8fb808
3ab77bf271e6a41512e366dfa5110edb981ed1d3
913f53e4c8a464c46a70898c88f2291ade28c196
f2c31662762b9e82b9891d6b385b17f9e5ef0ed2

Cheers,
Erwan
