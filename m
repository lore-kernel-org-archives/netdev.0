From: Dmitry Kozlov <xeb@mail.ru>
Subject: Re: [PATCH net-next v2] GRE over IPv6
Date: Sun, 29 Jul 2012 09:31:27 +0400
Message-ID: <20120729093127.53091c1d@comp1>
References: <20120728113512.3ffd8248@comp1>
	<877gtn3akt.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp24.mail.ru ([94.100.176.177]:57104 "EHLO smtp24.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751194Ab2G2Fbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2012 01:31:34 -0400
In-Reply-To: <877gtn3akt.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman <ebiederm@xmission.com> wrote:

> Why are you implementing an ioctl based instead of using netlink?
> Last I looked using netlink to create and delete tunnels was more
> flexible and the preferred method and the existing ioctl based methods
> were simply being maintained for backwards compatibility.
I have implemented both ioctl and netlink based.
So if ioctl based is unnecessary it is not difficult to remove this
part.

> Also it appears that you have failed to include the all important
> ip6_gre.c
What do you mean ?
