From: Ariane Keller <arkeller@ee.ethz.ch>
Subject: [GENETLINK] get pid from userspace
Date: Wed, 06 Jun 2007 12:13:38 +0200
Message-ID: <20070606121338.72lwb34vc4soogw8@email.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	format="flowed"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:47324 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757789AbXFFKVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2007 06:21:17 -0400
Received: from localhost (localhost [127.0.0.1])
	by smtp.ee.ethz.ch (Postfix) with ESMTP id 0E530D9356
	for <netdev@vger.kernel.org>; Wed,  6 Jun 2007 12:13:39 +0200 (MEST)
Received: from smtp.ee.ethz.ch ([127.0.0.1])
	by localhost (.ee.ethz.ch [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id exfvdAyN7LTT for <netdev@vger.kernel.org>;
	Wed,  6 Jun 2007 12:13:38 +0200 (MEST)
Received: from localhost (thor.ee.ethz.ch [129.132.2.232])
	by smtp.ee.ethz.ch (Postfix) with ESMTP id C8B7DD9324
	for <netdev@vger.kernel.org>; Wed,  6 Jun 2007 12:13:38 +0200 (MEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have a user space program which "connects" to different kernel 
modules with generic netlink. Each module provides its own generic 
netlink family.

For each module to "connect" to I create a socket and bind it:
fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_GENERIC);
struct sockaddr_nl addr;
memset(&addr, 0, sizeof(addr));
bind(fd, (struct sockaddr *)&addr, sizeof(addr));

As far as I understand, this lets the generic netlink controller choose 
a unique pid, which shows up in the kernel module in the callback 
function as genl_info.snd_pid.

Is it possible to get this pid in userspace (without sending a message 
to the kernel module)?

Thanks!

Ariane




