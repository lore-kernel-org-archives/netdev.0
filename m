From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2 0/2] Fix compiler-errors with gcc 4.7.3
Date: Mon, 22 Jul 2013 10:34:32 -0700
Message-ID: <20130722103432.396f13db@nehalam.linuxnetplumber.net>
References: <1374513857-6096-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:51265 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932302Ab3GVRef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 13:34:35 -0400
Received: by mail-pd0-f180.google.com with SMTP id 10so7042980pdi.25
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 10:34:35 -0700 (PDT)
In-Reply-To: <1374513857-6096-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Jul 2013 19:24:15 +0200
Christoph Paasch <christoph.paasch@uclouvain.be> wrote:

> gcc complains about unused return-values in ss.c and lnstat_util.c
> 
> Christoph Paasch (2):
>   ss: Fix compiler errors of unused return-values
>   lnstat: Fix compiler errors of unused return-values
> 
>  misc/lnstat_util.c | 12 ++++++++----
>  misc/ss.c          | 33 ++++++++++++++++++++++++---------
>  2 files changed, 32 insertions(+), 13 deletions(-)
> 

I think just turning on -Werror is less ugly.
