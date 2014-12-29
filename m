From: Shahar Lev <shahar@stratoscale.com>
Subject: Re: [PATCH] ipnetns: fix exec for netns not in NETNS_RUN_DIR
Date: Mon, 29 Dec 2014 11:25:41 +0200
Message-ID: <CAH04KvnHRsss5h+7KnGc52QK3UhJYS9yZ+8XPCQqnCjYsqpEug@mail.gmail.com>
References: <1419611232-14206-1-git-send-email-shahar@stratoscale.com>
	<20141227100548.4fbd3e31@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:65495 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbaL2JZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 04:25:42 -0500
Received: by mail-oi0-f51.google.com with SMTP id e131so28361223oig.10
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 01:25:41 -0800 (PST)
In-Reply-To: <20141227100548.4fbd3e31@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> This breaks existing users since you now require full pathname.
>

Providing a full path is not a requirement.
If there's no dash ('/') in the parameter provided it defaults to
opening relative to NETNS_RUN_DIR (the existing behavior).
So this is just an extension.
