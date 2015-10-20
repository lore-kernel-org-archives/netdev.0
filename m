From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Routing Policy Database Rule 0
Date: Tue, 20 Oct 2015 10:45:48 +0200
Message-ID: <20151020084548.GC25435@pox.localdomain>
References: <56259FB9.8020706@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Laing <Richard.Laing@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:33011 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587AbbJTIpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 04:45:50 -0400
Received: by wijp11 with SMTP id p11so36062469wij.0
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 01:45:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <56259FB9.8020706@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/15 at 01:58am, Richard Laing wrote:
> Hi,
> 
> We recently found a bug in our code which resulted in rule 0 in the 
> routing policy database being deleted, this is a bad thing and the man 
> page documentation for "ip rule" indicates
> 
> Rule 0 is special. It cannot be deleted or overridden.
> 
> which seems entirely reasonable. The code in net/core/fib_rules.c does 
> not seem to protect against deletion of this rule and I was wondering if 
> there is a reason for this. If not I will submit a patch to address it.

This behaviour was changed in commit 5adef1809
("net: fib_rules: allow to delete local rule") so it seems the manual
page is outdated. Feel free to send a patch.

> Simply running "ip rule del" shows the issue .

This however looks like a bug.
