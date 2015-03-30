From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] ip-link: allow human readable output with base of
 1024 only for byte counts
Date: Sun, 29 Mar 2015 22:58:35 -0700
Message-ID: <20150329225835.2cf0f770@uryu.home.lan>
References: <1427369048-1433-1-git-send-email-list@eworm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Christian Hesse <mail@eworm.de>
To: Christian Hesse <list@eworm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:32835 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288AbbC3F6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 01:58:40 -0400
Received: by pdnc3 with SMTP id c3so165223032pdn.0
        for <netdev@vger.kernel.org>; Sun, 29 Mar 2015 22:58:39 -0700 (PDT)
In-Reply-To: <1427369048-1433-1-git-send-email-list@eworm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Mar 2015 12:24:08 +0100
Christian Hesse <list@eworm.de> wrote:

> From: Christian Hesse <mail@eworm.de>
> 
> Counting bytes with a base of 1024 is ok. Counting packets, errors, etc
> that way makes no sense.
> So only print byte counts with a base of 1024 if option -iec is given.
> 
> Signed-off-by: Christian Hesse <mail@eworm.de>

This changes the output which users expect, especially the packet counts
should follow existing practice. And I doubt anyone would have 1024 errors.
