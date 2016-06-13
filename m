From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: [ethtool PATCH v1 0/2] Add support for QSFP+/QSFP28 Diagnostics
Date: Mon, 13 Jun 2016 16:27:04 -0700
Message-ID: <1465860426-30387-1-git-send-email-vidya@cumulusnetworks.com>
Cc: bkenward@solarflare.com, daniel@iogearbox.net, galp@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	dustin@cumulusnetworks.com
To: ben@decadent.org.uk, netdev@vger.kernel.org, bwh@kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36666 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbcFMX1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 19:27:12 -0400
Received: by mail-pa0-f50.google.com with SMTP id b5so49972104pas.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 16:27:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

This patch series provides following support
a) Reorganized fields based out of SFF-8024 fields i.e. Identifier/
   Encoding/Connector types which are common across SFP/SFP+ (SFF-8472)
   and QSFP+/QSFP28 (SFF-8436/SFF-8636) modules into sff-common files.
b) Support for diagnostics information for QSFP Plus/QSFP28 modules
   based on SFF-8436/SFF-8636
c) Tested across various SFP+/QSFP+/QSFP28 Copper/Optical modules

Standards for QSFP+/QSFP28
a) QSFP+/QSFP28 - SFF 8636 Rev 2.7 dated January 26,2016
b) SFF-8024 Rev 4.0 dated May 31, 2016

v1:
  Support for SFF-8636 Rev 2.7
  Review comments from Ben Hutchings:
   Updating copyright holders information for QSFP
   Reusing the common functions and macros across sfpid and qsfp 
     
############################################
# Patch Set Summary:

Vidya Sagar Ravipati (2):
  ethtool-copy.h:sync with net
  ethtool:QSFP Plus/QSFP28 Diagnostics Information Support

 Makefile.am    |   2 +-
 ethtool-copy.h |  17 +-
 ethtool.c      |   5 +
 internal.h     |   3 +
 qsfp.c         | 876 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 qsfp.h         | 599 +++++++++++++++++++++++++++++++++++++++
 sff-common.c   | 255 +++++++++++++++++
 sff-common.h   | 156 ++++++++++
 sfpid.c        | 103 +------
 9 files changed, 1912 insertions(+), 104 deletions(-)
 create mode 100644 qsfp.c
 create mode 100644 qsfp.h
 create mode 100644 sff-common.c
 create mode 100644 sff-common.h

-- 
2.1.4
