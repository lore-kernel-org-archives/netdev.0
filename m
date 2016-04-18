From: Ilan Tayari <ilant@mellanox.com>
Subject: RE: switchdev fib offload issues
Date: Mon, 18 Apr 2016 16:38:18 +0000
Message-ID: <AM4PR0501MB19409325D618C1C2E9519E9FDB6B0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
References: <20160418154757.GA2059@nanopsycho.amit.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0056.outbound.protection.outlook.com ([104.47.2.56]:24192
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753262AbcDRQyD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 12:54:03 -0400
In-Reply-To: <20160418154757.GA2059@nanopsycho.amit.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

> Thoughts?

One general thought comes to mind, regardless of your proposed solutions:

You'll need to take care to propagate the error properly in case of routes created by the kernel, such as local routes.
Local routes are created when an IP address is added to an interface, so in such a case would the whole add-ip-address operation be rolled back cleanly?

Ilan.
