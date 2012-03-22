From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: long-lived tcp connection question
Date: Thu, 22 Mar 2012 22:51:50 +0100
Message-ID: <20120322215150.GB3093@nuttenaction>
References: <CAKA=qzaPwx53ExK7VhNC_sbv3tVZrnWXv-5Fh8akcZ6DEaqd9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Josh Hunt <joshhunt00@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:52206 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S965162Ab2CVWCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 18:02:18 -0400
Content-Disposition: inline
In-Reply-To: <CAKA=qzaPwx53ExK7VhNC_sbv3tVZrnWXv-5Fh8akcZ6DEaqd9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Josh Hunt | 2012-03-22 11:56:19 [-0500]:

>Given things like web sockets with presumably long-lived persistent
>tcp connections and a sparse amount of data, I was wondering if there
>are currently any mechanisms in the kernel or out of tree projects
>which work on reducing the overhead these connections require?
>Possibly storing their state after a certain period of inactivity and
>then reviving them when work needs to be done? I'm thinking something
>along the lines of the state info stored for time-wait sockets and
>then the ability to resurrect it on an incoming packet. Keeping
>resources around for such connections seems inefficient although
>possibly unavoidable.

Do you referring to something like this:

https://datatracker.ietf.org/doc/draft-ietf-tcpm-fastopen/

The Linux code is not released yet, but I know that the required storage
overhead is small. Search the IETF email archive for more background
information about the topic.

Hagen
