From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bug 6688] Memory allocation problem
Date: Tue, 20 Jun 2006 00:24:33 -0700
Message-ID: <20060620002433.28115714.akpm@osdl.org>
References: <200606200646.k5K6k8Z3009667@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:2178 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965115AbWFTHYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 03:24:35 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k5K7OXgt012036
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 20 Jun 2006 00:24:34 -0700
Received: from box (shell0.pdx.osdl.net [10.9.0.31])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with SMTP id k5K7OX4a032198
	for <netdev@vger.kernel.org>; Tue, 20 Jun 2006 00:24:33 -0700
To: netdev@vger.kernel.org
In-Reply-To: <200606200646.k5K6k8Z3009667@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Jun 2006 23:46:08 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=6688

This is looking like a net memory leak in 2.6.16.  1/3rd is in ip_fib_alias
and 2/3rds is in size-64.  I've asked the reporter to apply the leak
detector patch so we can find out who is using the size-64 part.
