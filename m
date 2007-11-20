From: "Jesper Bengtsson" <jesper.bengtsson@axis.com>
Subject: Async crypto support in IPsec
Date: Tue, 20 Nov 2007 08:22:29 +0100
Message-ID: <BFECAF9E178F144FAEF2BF4CE739C668039A0CD0@exmail1.se.axis.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from miranda.se.axis.com ([193.13.178.8]:45517 "EHLO
	miranda.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752880AbXKTHWd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 02:22:33 -0500
Received: from exgate.se.axis.com (exgate.se.axis.com [10.0.5.55])
	by miranda.se.axis.com (8.13.4/8.13.4/Debian-3sarge3) with SMTP id lAK7MV6K026973
	for <netdev@vger.kernel.org>; Tue, 20 Nov 2007 08:22:31 +0100
content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm investigating IPsec with hw-accelerated encryption, using the AXIS
crisv32 built-in crypto accelerator.
The crisv32 crypto accelerator does however require asynchronous crypto
support in crypto API and IPsec stack.

I've seen that async crypto support made it's way into the crypto API in
2.6.22.
>From skimming the netdev-list I can see that some of you are working on
async crypto support in IPsec as well. Do you have any idea when it will
be available?

The crisv32 crypto accelerator supports hashing and encryption in one
single operation. Do you have any plans for supporting hashing and
encryption in one operation?

Thanks in advance,
Jesper
