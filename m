From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Possible to add netfilter hooks to IFB driver?
Date: Mon, 6 Jan 2014 13:51:23 -0800
Message-ID: <20140106135123.3c7e6645@nehalam.linuxnetplumber.net>
References: <522653F1.6090902@ecessa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brad Johnson <bjohnson@ecessa.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35095 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756028AbaAFVvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 16:51:48 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so19157965pab.35
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 13:51:47 -0800 (PST)
In-Reply-To: <522653F1.6090902@ecessa.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 03 Sep 2013 16:26:09 -0500
Brad Johnson <bjohnson@ecessa.com> wrote:

> I would like to add netfilter hooks to the IFB driver so I can do 
> iptables -j IFB (just like we can with IMQ). But I would like to know 
> first if there are any reasons this can not work. Please advise if this 
> is possible, and if so any tips would be appreciated.
> 
> Cheers,
> Brad

The risk is creating the same races that made IMQ unacceptable.
