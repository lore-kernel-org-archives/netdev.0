From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] Changed action labels to [action ] format
Date: Fri, 10 Oct 2014 15:56:48 -0500
Message-ID: <20141010155648.1f1b51bf@uryu.home.lan>
References: <1412959916-32169-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:34559 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292AbaJJU45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 16:56:57 -0400
Received: by mail-ig0-f182.google.com with SMTP id hn15so4283326igb.9
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 13:56:56 -0700 (PDT)
In-Reply-To: <1412959916-32169-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Oct 2014 19:51:56 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> The reasons for this change were:
>     - different ip utils uses different labels for action: Deleted/delete
>     - make an action labels to be easy found in logs

Fine in concept. But people do stupid things like parse the output of commands.
I am loathe to make cosmetic change.
