From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/6] drivers: net: ethernet: cpsw: add support for CPSW
 register offset changes in different IP version
Date: Mon, 22 Oct 2012 14:25:25 +0200
Message-ID: <20121022122524.GA6151@netboy.at.omicron.at>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-2-git-send-email-mugunthanvnm@ti.com>
 <20121018024523.GA2867@netboy.at.omicron.at>
 <EB1619762EAF8B4E97A227FB77B7E0293E9FD69E@DBDE01.ent.ti.com>
 <20121022112334.GB2285@netboy.at.omicron.at>
 <EB1619762EAF8B4E97A227FB77B7E0293E9FD8B7@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "N, Mugunthan V" <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:55705 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087Ab2JVMZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 08:25:35 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so2404900wib.1
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 05:25:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <EB1619762EAF8B4E97A227FB77B7E0293E9FD8B7@DBDE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 22, 2012 at 12:19:44PM +0000, N, Mugunthan V wrote:
> 
> Only the slave register offsets are different, so once slave register
> offset is taken care in CPSW driver, then we can directly use CPSW
> when DM81XX base port patches are available for vanilla kernel.
> No need to revisit the driver again when bringing up DM81XX.

Fine with me. It is really up to you how and when you want to get the
CPSW working, if ever.

But at this rate, it won't be working in v3.7, not even for am335x,
and v3.8 isn't looking too good either.

Oh well,
Richard
