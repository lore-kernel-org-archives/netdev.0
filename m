From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH RFC 0/2] Add extended pause query capability
Date: Fri, 14 Oct 2011 13:54:00 -0700
Message-ID: <1318625642-9668-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	bhutchings@solarflare.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2607 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932432Ab1JNUyC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Oct 2011 16:54:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current implementation of get_pauseparam allows userspace to query the
flow control configuration, but not the flow control status.  This patchset
defines a new ethtool_pauseparamext structure and adds a new
get_pauseparamext ethtool callback to support it.  The new facilities allow
the driver to report both config and status in the same query.

Please note that Ben Hutchings' suggestion to deduce the flow control settings
through the 'advertising' and 'lp_advertising' from ETHTOOL_GSET was considered,
but rejected because there was no way to know if the flow control
advertisements reported were valid.
