From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH] TCPCT-1: adding a sysctl
Date: Fri, 02 Oct 2009 13:52:17 -0400
Message-ID: <4AC63DD1.3030705@gmail.com>
References: <4AC57AC5.3080703@gmail.com> <20091001225705.788d38ba@nehalam> <4AC61505.8030701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:64528 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbZJBRwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 13:52:43 -0400
Received: by qw-out-2122.google.com with SMTP id 3so476054qwe.37
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2009 10:52:47 -0700 (PDT)
In-Reply-To: <4AC61505.8030701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson wrote:
> This is a straightforward re-implementation of an earlier patch, that no
> longer applies cleanly, that was reviewed:
> 
>   http://thread.gmane.org/gmane.linux.network/102586
> 
In that thread, David Miller wrote:

   "This looks mostly fine to me.  I would even advocate not using a config
   option for this."

It would make the code look cleaner, and with the sysctl instead, it
would probably be fine.  But SYN cookies has both.

Before I go much further, I'd like guidance.
