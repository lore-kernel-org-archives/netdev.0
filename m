From: "David Madsen" <david.madsen@gmail.com>
Subject: Re: r8169: slow samba performance
Date: Sun, 9 Sep 2007 00:44:42 -0700
Message-ID: <ec7e30370709090044m55efbbcl3cb9e9489f2d5e6e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.184]:48967 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbXIIHon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2007 03:44:43 -0400
Received: by fk-out-0910.google.com with SMTP id z23so900631fkz
        for <netdev@vger.kernel.org>; Sun, 09 Sep 2007 00:44:42 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>Does "acceptable" mean that there is a noticeable difference when compared
>to the patch based on a busy-waiting loop ?

I noticed a somewhat significant difference between patch #0002 and a
busy wait loop with ndelay(10). Write performance was equivalent in
both cases as should be the case.  Read perfomance for me maxed out
around 150ish megabit whereas switching to the ndelay(10) loop brought
up average performance around 350ish megabit while reading the same
files over samba.

--David Madsen
