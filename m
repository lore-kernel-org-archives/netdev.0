From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] macsec: fix input range of 'icvlen' parameter
Date: Tue, 20 Sep 2016 09:49:05 -0700
Message-ID: <20160920094905.19a4c837@xeon-e3>
References: <b1f730436465e511edb56e4486299e4f3835599b.1473428548.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>,
        Phil Sutter <phil@nwl.cc>
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:32847 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932853AbcITQsz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 12:48:55 -0400
Received: by mail-pf0-f178.google.com with SMTP id 21so9187263pfy.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 09:48:55 -0700 (PDT)
In-Reply-To: <b1f730436465e511edb56e4486299e4f3835599b.1473428548.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  9 Sep 2016 16:02:22 +0200
Davide Caratti <dcaratti@redhat.com> wrote:

> the maximum possible ICV length in a MACsec frame is 16 octects, not 32:
> fix get_icvlen() accordingly, so that a proper error message is displayed
> in case input 'icvlen' is greater than 16.
> 
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>

Applied
