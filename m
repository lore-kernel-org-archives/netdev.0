From: "Tom Herbert" <therbert@google.com>
Subject: SO_REUSEPORT?
Date: Thu, 7 Aug 2008 09:57:15 -0700
Message-ID: <65634d660808070957j12e1f93rfb577efabc771c9a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:22818 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752636AbYHGQ5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 12:57:19 -0400
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id m77GvGh1018341
	for <netdev@vger.kernel.org>; Thu, 7 Aug 2008 17:57:16 +0100
Received: from rv-out-0506.google.com (rvbl9.prod.google.com [10.140.88.9])
	by wpaz24.hot.corp.google.com with ESMTP id m77Guuo1017249
	for <netdev@vger.kernel.org>; Thu, 7 Aug 2008 09:57:15 -0700
Received: by rv-out-0506.google.com with SMTP id l9so465426rvb.47
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2008 09:57:15 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We are looking at ways to scale TCP listeners.  I think we like is the
ability to listen on a port from multiple threads (sockets bound to
same port,  INADDR_ANY, and no interface binding) , which is what
SO_REUSEPORT would seem to allow.  Has this ever been implemented for
Linux or is there a good reason not to have it?

Thanks,
Tom
