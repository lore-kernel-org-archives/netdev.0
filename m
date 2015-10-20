From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is
 incorrect for sockets in accept(3)
Date: Tue, 20 Oct 2015 06:19:33 -0700
Message-ID: <1445347173.22974.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151019095938.72ea48e6@xeon-e3>
	 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <562594E1.8040403@oracle.com>
	 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56261092.7080003@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33185 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbbJTNTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 09:19:35 -0400
Received: by pabrc13 with SMTP id rc13so21684392pab.0
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 06:19:34 -0700 (PDT)
In-Reply-To: <56261092.7080003@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-10-20 at 10:59 +0100, Alan Burlison wrote:

> That may be how Linux implements accept(), but I don't see anything 
> about refcounting in the POSIX spec for accept().

That's an internal implementation detail. POSIX does not document linux
kernel overall design and specific tricks.

linux is GPL, while Solaris is proprietary code. There is quite a
difference, and we do not want to copy Solaris behavior. We want our own
way, practical, and good enough.

If POSIX makes sense we try to be compliant. If not, we do not.

If you are interested, take a look at fs/* code, and try to implement
your proposal and keep good performance.

You might find a clever way, without infringing prior art. We did not
yet.
