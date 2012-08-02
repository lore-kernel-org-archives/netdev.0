From: "Tobias S. Josefowitz" <t.josefowitz@gmail.com>
Subject: Re: binding UDP port 0 with SO_REUSEADDR
Date: Thu, 2 Aug 2012 21:05:15 +0200
Message-ID: <CAEZM=bOpJZO6w7-+0HOpbpJXmmhibw91NquBzXKf6TAnxKuXDA@mail.gmail.com>
References: <CAEZM=bNdyZoTiGYwNM_3v+ro7dEn0q9aTo4040tBDqDSH3HOXg@mail.gmail.com>
	<1343847776.21269.797.camel@edumazet-glaptop>
	<CAEZM=bPqOgRUvUKfdYkrVXoWin+SMft0GK67hqsGhBD6nocryA@mail.gmail.com>
	<CAEZM=bM=AGp=FOxLiDiBFgVJWGmNdPpG_FV3Ne2i5jeALiB4YA@mail.gmail.com>
	<1343926645.9299.303.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:53079 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753242Ab2HBTFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 15:05:20 -0400
Received: by obbuo13 with SMTP id uo13so14230277obb.19
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2012 12:05:19 -0700 (PDT)
In-Reply-To: <1343926645.9299.303.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 2, 2012 at 6:57 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> There is no value using 'port 0' and REUSEADDR on UDP, really.

And nobody ever makes mistakes, so why not surprise them for even more
than they are in for.

"Looking into src/pkg/net/sock.go (func socket) I see that SO_REUSEADDR
is set unconditionally to all types of sockets." --
http://code.google.com/p/go/issues/detail?id=1692

Anyway, I'm out of this now.

Tobi
