From: "Tom Burns" <tom.i.burns@gmail.com>
Subject: sky2: call sky2_set_multicast from sky2_restart?
Date: Fri, 18 Jan 2008 14:30:52 -0500
Message-ID: <671c20540801181130w4ec704acu42a89a78e8b84cb3@mail.gmail.com>
References: <671c20540801181120i55bd8ff0r8385636d1ce5b2e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.230]:25924 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760575AbYARTaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 14:30:52 -0500
Received: by wr-out-0506.google.com with SMTP id c49so507583wra.1
        for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 11:30:52 -0800 (PST)
In-Reply-To: <671c20540801181120i55bd8ff0r8385636d1ce5b2e@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi List,

Throughout the sky2.c file any call to sky2_up(dev) is followed (soon
enough) by a call to sky2_set_multicast(dev).  Should this not also be
the case when it is called in sky2_restart()?

Cheers,
Tom Burns
