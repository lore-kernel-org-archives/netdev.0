From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] libnetlink: Fix extack attribute parsing
Date: Fri, 18 Aug 2017 08:48:37 -0700
Message-ID: <20170818084837.0bcc6ff2@xeon-e3>
References: <1503002580-21267-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:33409 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750944AbdHRPsq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 11:48:46 -0400
Received: by mail-pg0-f45.google.com with SMTP id t3so38771812pgt.0
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 08:48:46 -0700 (PDT)
In-Reply-To: <1503002580-21267-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Aug 2017 13:43:00 -0700
David Ahern <dsahern@gmail.com> wrote:

> Initialize tb in nl_dump_ext_err since not all attributes will be
> sent in the messages.
> 
> Add error checking on mnl_attr_parse and print messages on the off
> chance the ext ack attributes fail to validate.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied, thanks David
