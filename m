From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/1] net: sctp: dynamically enable or disable pf state
Date: Mon, 14 Dec 2015 09:53:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBEC9E2@AcuExch.aculab.com>
References: <1449824732-22362-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "'zyjzyj2000@gmail.com'" <zyjzyj2000@gmail.com>,
	"vyasevich@gmail.com" <vyasevich@gmail.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"alexandre.dietsch@windriver.com" <alexandre.dietsch@windriver.com>,
	"stefan.costandache@windriver.com" <stefan.costandache@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.194]:52204 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932150AbbLNJ4N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 04:56:13 -0500
In-Reply-To: <1449824732-22362-1-git-send-email-zyjzyj2000@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: zyjzyj2000@gmail.com
> Sent: 11 December 2015 09:06
...
> +pf_enable - INTEGER
> +	Enable or disable pf state. A value of pf_retrans > path_max_retrans
> +	also disables pf state. That is, one of both pf_enable and
> +	pf_retrans > path_max_retrans can disable pf state. Since pf_retrans
> +	and path_max_retrans can be changed by userspace application, sometimes
> +	user expects to disable pf state by the value of
> +	pf_retrans > path_max_retrans, but ocassionally the value of pf_retrans
> +	or path_max_retrans is changed by the user application, this pf state is
> +	enabled. As such, it is necessary to add this to dynamically enable
> +	and disable pf state.
> +
> +	1: Enable pf.
> +
> +	0: Disable pf.
> +
> +	Default: 1

You ought to say what 'pf' is short for.

	David
