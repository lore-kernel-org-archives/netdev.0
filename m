From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH net-next] rndis_host: pass buffer length to rndis_command
Date: Wed, 18 Jun 2008 10:09:10 -0700
Message-ID: <200806181009.10193.david-b@pacbell.net>
References: <20080618124011.11920.98218.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp116.sbc.mail.sp1.yahoo.com ([69.147.64.89]:31920 "HELO
	smtp116.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755287AbYFRRJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 13:09:12 -0400
In-Reply-To: <20080618124011.11920.98218.stgit@fate.lan>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 18 June 2008, Jussi Kivilinna wrote:
> Pass buffer length to rndis_command so that rndis_command can read full
> response buffer from device instead of max CONTROL_BUFFER_SIZE bytes.

That is:  allow rndis_wlan to get responses *bigger* than that size,
while preserving the requirement that the host must always be ready
to receive that many bytes.

 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Acked-by: David Brownell <dbrownell@users.sourceforge.net>

