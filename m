From: "Tobias S. Josefowitz" <t.josefowitz@gmail.com>
Subject: Re: binding UDP port 0 with SO_REUSEADDR
Date: Thu, 2 Aug 2012 18:33:43 +0200
Message-ID: <CAEZM=bM=AGp=FOxLiDiBFgVJWGmNdPpG_FV3Ne2i5jeALiB4YA@mail.gmail.com>
References: <CAEZM=bNdyZoTiGYwNM_3v+ro7dEn0q9aTo4040tBDqDSH3HOXg@mail.gmail.com>
	<1343847776.21269.797.camel@edumazet-glaptop>
	<CAEZM=bPqOgRUvUKfdYkrVXoWin+SMft0GK67hqsGhBD6nocryA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:63409 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753337Ab2HBQdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 12:33:44 -0400
Received: by qadb17 with SMTP id b17so3516339qad.19
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2012 09:33:43 -0700 (PDT)
In-Reply-To: <CAEZM=bPqOgRUvUKfdYkrVXoWin+SMft0GK67hqsGhBD6nocryA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again,

I need to say, after looking at "my" socket(7),

       SO_REUSEADDR
              Indicates  that  the rules used in validating addresses supplied
              in a bind(2) call should allow reuse of  local  addresses.   For
              AF_INET  sockets  this means that a socket may bind, except when
              there is an active listening socket bound to the address.   When
              the listening socket is bound to INADDR_ANY with a specific port
              then it is not possible to bind  to  this  port  for  any  local
              address.  Argument is an integer boolean flag.

I think the surprise-factor of the bind-0-behaviour even increased for
me. Is there a specific reason for handing out used ports when binding
port 0 with REUSEADDR?

Best,

Tobi
