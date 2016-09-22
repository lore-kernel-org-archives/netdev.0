From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] misc/ss: tcp cwnd should be unsigned
Date: Thu, 22 Sep 2016 16:39:22 -0700
Message-ID: <20160922163922.32cc6784@xeon-e3>
References: <1474533628-5784-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35171 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757387AbcIVXjM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 19:39:12 -0400
Received: by mail-pf0-f177.google.com with SMTP id s13so986700pfd.2
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 16:39:12 -0700 (PDT)
In-Reply-To: <1474533628-5784-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Sep 2016 16:40:28 +0800
Hangbin Liu <liuhangbin@gmail.com> wrote:

> tcp->snd_cwd is a u32, but ss treats it like a signed int. This may
> results in negative bandwidth calculations.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Sure applied.
