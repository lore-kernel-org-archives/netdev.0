From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: Fix typo in get_prefix_1()
Date: Mon, 11 May 2015 09:12:19 -0700
Message-ID: <20150511091219.2afc962b@urahara>
References: <1051c439b96abe2cf554720d5f7b456c48ebd838.1430784770.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:32920 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbbEKQMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 12:12:17 -0400
Received: by pdbnk13 with SMTP id nk13so149933266pdb.0
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 09:12:16 -0700 (PDT)
In-Reply-To: <1051c439b96abe2cf554720d5f7b456c48ebd838.1430784770.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  5 May 2015 02:14:16 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> Fixes a typo in get_prefix_1() which broke the prefix default
> names { default | any | all }.
> 
> The most obvious fallout from this bug was:
> 
> 	$ ip route add default via 1.1.1.1
> 	Error: an inet prefix is expected rather than "default".
> 
> Fixes: dacc5d4197c1 ("add basic mpls support to iproute")
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied thanks
