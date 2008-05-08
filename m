From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: Debugging TCP: Treason Uncloaked
Date: Thu, 8 May 2008 11:01:25 -0400
Message-ID: <1e41a3230805080801hc994773pe0b3d5dadc5b36cb@mail.gmail.com>
References: <482265A0.8040105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Chris Bredesen" <cbredesen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.232]:6307 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757870AbYEHPB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 11:01:26 -0400
Received: by wr-out-0506.google.com with SMTP id c48so354652wra.1
        for <netdev@vger.kernel.org>; Thu, 08 May 2008 08:01:25 -0700 (PDT)
In-Reply-To: <482265A0.8040105@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 7, 2008 at 10:29 PM, Chris Bredesen <cbredesen@redhat.com> wrote:
> Hello,
>
>  As per below thread, I'm forwarding to this list/alias.  tcpdump output
>  is attached to the forum post.

Full binary tcpdumps (including the SYN packets) are more useful.

>From the brief snippet you have, we can't see where the announced
window was reneged, but it's 192.168.1.130 doing it, not the nas box.
You're also getting DSACKs from the nas box, which is also a bit
strange.

Another thing to try is disabling TSO, though I can't think why that
might be causing a problem here.

  -John
