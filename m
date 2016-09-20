From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv2 iproute2] ip route: check ftell, fseek return value
Date: Tue, 20 Sep 2016 09:53:22 -0700
Message-ID: <20160920095322.19a75d24@xeon-e3>
References: <1473301617-9123-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Laight <David.Laight@ACULAB.COM>,
        Phil Sutter <phil@nwl.cc>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36268 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932368AbcITQxM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 12:53:12 -0400
Received: by mail-pf0-f176.google.com with SMTP id q2so9169821pfj.3
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 09:53:12 -0700 (PDT)
In-Reply-To: <1473301617-9123-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  8 Sep 2016 10:26:57 +0800
Hangbin Liu <liuhangbin@gmail.com> wrote:

> ftell() may return -1 in error case, which is not handled and therefore pass a
> negative offset to fseek(). The return code of fseek() is also not checked.
> 
> Reported-by: Phil Sutter <phil@nwl.cc>
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Applied
