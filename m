From: Jesse White <jesse@opennms.org>
Subject: ICMPv6 sockets
Date: Sat, 12 Dec 2015 11:02:50 -0500
Message-ID: <566C452A.5000204@opennms.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.opennms.com ([64.34.187.168]:55421 "EHLO
	mail2.opennms.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297AbbLLQJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2015 11:09:03 -0500
Received: from [172.23.1.103] (cpe-45-37-71-140.nc.res.rr.com [45.37.71.140])
	by mail2.opennms.com (Postfix) with ESMTPSA id 41ED9A0096A
	for <netdev@vger.kernel.org>; Sat, 12 Dec 2015 11:05:26 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Support for IPPROTO_ICMP socket binds was added in commit c319b4d76b9e583a5d88d6bf190e079c4e43213d
which allow for process to send ICMP_ECHO messages (and receive the corresponding ICMP_ECHOREPLY messages)
without any special privileges.

There doesn't appear to be any similar functionality for IPPROTO_ICMPV6.

Would the net maintainers be open to including a patch that adds similar support for ICMPv6?

Thanks,
Jesse
