From: "P, Balakumaran (NSN - IN/Bangalore)" <balakumaran.p@nsn.com>
Subject: Ipaddress modification
Date: Mon, 22 Jun 2009 21:31:29 +0800
Message-ID: <9A920612ACA0144FBB2F8D874DA1EC692AC150@SGSIEXC017.nsn-intra.net>
References: <e31d15d70906220020y70f0daf9k4650d96c402fdf7a@mail.gmail.com> <20090622.002834.240476749.davem@davemloft.net> <e31d15d70906220612p7a27deb3y949c6693f1b5646a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([217.115.75.233]:12633 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731AbZFVNbc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 09:31:32 -0400
Received: from demuprx016.emea.nsn-intra.net ([10.150.129.55])
	by demumfd001.nsn-inter.net (8.12.11.20060308/8.12.11) with ESMTP id n5MDVXp6026177
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 22 Jun 2009 15:31:33 +0200
Received: from demuexc024.nsn-intra.net (demuexc024.nsn-intra.net [10.159.32.11])
	by demuprx016.emea.nsn-intra.net (8.12.11.20060308/8.12.11) with ESMTP id n5MDVV83013581
	for <netdev@vger.kernel.org>; Mon, 22 Jun 2009 15:31:33 +0200
Content-class: urn:content-classes:message
In-Reply-To: <e31d15d70906220612p7a27deb3y949c6693f1b5646a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, 

I am trying to run two socket client-server programs on the same machine
which use the same port nos ( also same ip address) independent of each
other.

I am planning to capture the bind request sent for a particular port no
and change it to a differen ip address and send it to the kernel and any
data sent to the port should be correctly transferred to the pertaining
program by maintaining a table.

Only way I could think of is to change during the bind request since I
need to modify it before the actual binding happens. Anybody got any
idea on this?

Thanks in advance.

Bala.

