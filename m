From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [patch] phonet: some signedness bugs
Date: Mon, 10 Jan 2011 09:58:32 +0200
Message-ID: <201101100958.32549.remi.denis-courmont@nokia.com>
References: <20110107203755.GB1959@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, dan.j.rosenberg@gmail.com
To: ext Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.128.24]:62781 "EHLO mgw-da01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751820Ab1AJH6Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 02:58:25 -0500
In-Reply-To: <20110107203755.GB1959@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 07 January 2011 22:37:55 ext Dan Carpenter, you wrote:
> Dan Rosenberg pointed out that there were some signed comparison bugs
> in the phonet protocol.

There are two ways to solve this: change *only* the proto_get function =
to use=20
an unsigned parameter, or cast the protocol to unsigned in the comparis=
on.

As David pointed out, your patch breaks the socket() callback prototype=
=2E

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki
