From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [BUG, regression, bisected] Marvell 88E8055 NIC (sky2) fails to detect link after resume from S3
Date: Fri, 29 Jun 2012 23:58:40 +0200
Message-ID: <20120629215840.GA21533@electric-eye.fr.zoreil.com>
References: <op.wgon84tw16tawo@esprimo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Michal Zatloukal <myxal.mxl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40361 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407Ab2F2WJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 18:09:43 -0400
Content-Disposition: inline
In-Reply-To: <op.wgon84tw16tawo@esprimo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(maintainers Cced)

Michal Zatloukal <myxal.mxl@gmail.com> :
[7afe1845dd1e7c90828c942daed7e57ffa7c38d6 induced regression]
> My uneducated guess is that by making the resume from S3 shorter, the
> driver catches the hardware with its pants down and freaks out.
> You can find all details/files (dmesg, lspci, dmidecode, config...)
> collected by apport in the ubuntu bug linked above. Let me know if I
> should supply any more info.
> Note: Please CC me into replies, I'm not subscribed. Thank you.

Can you workaround it by enforcing some mdelay() in sky2_resume before
it does any real work ?

-- 
Ueimor
