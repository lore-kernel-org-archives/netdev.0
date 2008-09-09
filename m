From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: mmotm 2008-09-08-18-32 uploaded
Date: Tue, 09 Sep 2008 11:32:10 +0200
Message-ID: <48C6429A.1040809@gmail.com>
References: <200809090135.m891ZHiW020337@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: mm-commits@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, romieu@fr.zoreil.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.236]:21748 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbYIIJcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 05:32:17 -0400
Received: by wx-out-0506.google.com with SMTP id h27so483162wxd.4
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2008 02:32:16 -0700 (PDT)
In-Reply-To: <200809090135.m891ZHiW020337@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org napsal(a):
> The mm-of-the-moment snapshot 2008-09-08-18-32 has been uploaded to

Hi,

CONFIG_MII=n
CONFIG_R8169=y

causes:
drivers/built-in.o: In function `rtl8169_gset_xmii':
r8169.c:(.text+0x8b4ec): undefined reference to `mii_ethtool_gset'

R8169 should depend on MII?
