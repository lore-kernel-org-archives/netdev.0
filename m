From: "David Laight" <David.Laight@ACULAB.COM>
Subject: sock_getsockopt() not exported
Date: Thu, 18 Oct 2012 10:11:40 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7052@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40461 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753479Ab2JRJNG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 05:13:06 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17953-10 for <netdev@vger.kernel.org>;
 Thu, 18 Oct 2012 10:13:04 +0100 (BST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've noticed that net/core/sock.c contains an
    EXPORT_SYMBOL(sock_setsockopt)
but is missing the corresponding
    EXPORT_SYMBOL(sock_getsockopt)

In-kernel users of sockets probably manage without
needing to read SOL_SOCKET options.
(They do need to set SO_REUSADDR and SO_KEEPALIVE.)

	David
