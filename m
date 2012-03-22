From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: long-lived tcp connection question
Date: Thu, 22 Mar 2012 15:29:54 -0700
Message-ID: <1332455394.6521.10.camel@edumazet-glaptop>
References: <CAKA=qzaPwx53ExK7VhNC_sbv3tVZrnWXv-5Fh8akcZ6DEaqd9Q@mail.gmail.com>
	 <20120322215150.GB3093@nuttenaction>
	 <CAKA=qzZ7K6gGJ88NR83nm1vNnRWiuwN-MbEVzeSRpuok7j2vTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Josh Hunt <joshhunt00@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:59414 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754255Ab2CVWaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 18:30:04 -0400
Received: by iagz16 with SMTP id z16so3710629iag.19
        for <netdev@vger.kernel.org>; Thu, 22 Mar 2012 15:30:04 -0700 (PDT)
In-Reply-To: <CAKA=qzZ7K6gGJ88NR83nm1vNnRWiuwN-MbEVzeSRpuok7j2vTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-03-22 at 17:27 -0500, Josh Hunt wrote:
> On Thu, Mar 22, 2012 at 4:51 PM, Hagen Paul Pfeifer <hagen@jauu.net> wrote:
> > * Josh Hunt | 2012-03-22 11:56:19 [-0500]:
> >
> >>Given things like web sockets with presumably long-lived persistent
> >>tcp connections and a sparse amount of data, I was wondering if there
> >>are currently any mechanisms in the kernel or out of tree projects
> >>which work on reducing the overhead these connections require?
> >>Possibly storing their state after a certain period of inactivity and
> >>then reviving them when work needs to be done? I'm thinking something
> >>along the lines of the state info stored for time-wait sockets and
> >>then the ability to resurrect it on an incoming packet. Keeping
> >>resources around for such connections seems inefficient although
> >>possibly unavoidable.
> >
> > Do you referring to something like this:
> >
> > https://datatracker.ietf.org/doc/draft-ietf-tcpm-fastopen/
> >
> > The Linux code is not released yet, but I know that the required storage
> > overhead is small. Search the IETF email archive for more background
> > information about the topic.
> >
> > Hagen
> >
> 
> No, this deals more with the overhead of establishing a connection.
> I'm asking more about the overhead associated with holding on to
> long-lived connections which may not be doing much.
> 

So what are the actual numbers for this overhead per socket ?
