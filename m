From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tipc: introduce TIPC configuration tool
Date: Thu, 21 May 2015 14:43:40 -0700
Message-ID: <20150521144340.1b112c0a@urahara>
References: <1431004056-6282-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: <richard.alpe@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:33305 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755974AbbEUVnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 17:43:37 -0400
Received: by pdbqa5 with SMTP id qa5so657052pdb.0
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 14:43:36 -0700 (PDT)
In-Reply-To: <1431004056-6282-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 7 May 2015 15:07:35 +0200
<richard.alpe@ericsson.com> wrote:

> From: Richard Alpe <richard.alpe@ericsson.com>
> 
> This is the new tipc tool that utilizes the relativly new TIPC netlink API in
> the kernel. Introducing this tool into iproute2 has been discussed previously.
> 
> For more information about the design decisions of this tool, see the README
> file.
> 
> There isn't yet a manpage for the this tool. I will start to write one once I
> submitted this for review.
> 
> Richard Alpe (1):
>   tipc: add new TIPC configuration tool

I went ahead and merged this.
It does add dependency on libmnl which the distribution maintainers will have
to add to their stuff.
