From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET] Validation for netlink string attributes
Date: Tue, 22 Aug 2006 14:53:54 +0200
Message-ID: <20060822125354.196502354@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:46813 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932171AbWHVM72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 08:59:28 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Validation of netlink string attributes was weak, forcing everyone
to use nla_strlcpy() to copy the attribute into a temporary buffer.

This patchset implements length validation checks for existing
NLA_STRING attributes and adds a new type NLA_NUL_STRING for
NUL terminated strings.

