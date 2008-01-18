From: Chuck Ebbert <cebbert@redhat.com>
Subject: Memory leak in security_netlbl_sid_to_secattr(), kernel 2.6.23.12
Date: Fri, 18 Jan 2008 18:19:51 -0500
Message-ID: <47913417.3090504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57814 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751933AbYARXT6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 18:19:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have two reports of this now.

https://bugzilla.redhat.com/show_bug.cgi?id=352281

The user enabled SLUB user tracing and reports that the entries
created by security_netlbl_sid_to_secattr() were increasing the
most.  Disabling selinux makes the problem go away completely.

