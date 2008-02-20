From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] SUNRPC: Mark buffer used for debug printks with
	__maybe_unused
Date: Wed, 20 Feb 2008 07:31:54 -0800
Message-ID: <1203521514.7181.167.camel@localhost>
References: <47BC3303.2040101@openvz.org>
	 <1203521357.7181.163.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:1068 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1765664AbYBTPcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 10:32:25 -0500
In-Reply-To: <1203521357.7181.163.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-02-20 at 07:29 -0800, Joe Perches wrote:
> fs/nfsd/nfsproc.c:              char buf[RPC_MAX_ADDRBUFLEN];
> Perhaps there should be a DECLARE_RPC_BUF(buf) macro?
> #define DECLARE_RPC_BUF(var) char var[MAC_BUF_SIZE] __maybe_unused

Make that:

#define DECLARE_RPC_BUF(var) char var[RPC_MAX_ADDRBUFLEN] __maybe_unused


