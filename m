From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [PATCH] tcp_probe: __attribute__ string location
Date: Wed, 6 Jun 2007 15:15:30 +1200
Message-ID: <5640c7e00706052015tda24904mea8732a79236d4b6@mail.gmail.com>
References: <20070605180141.e4692374.randy.dunlap@oracle.com>
	 <20070605.190518.75190350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, netdev@vger.kernel.org,
	"Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>,
	"Patrick Andrieux" <patrick.andrieux@gmail.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.238]:65371 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbXFFDPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 23:15:31 -0400
Received: by nz-out-0506.google.com with SMTP id n1so11168nzf
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2007 20:15:30 -0700 (PDT)
In-Reply-To: <20070605.190518.75190350.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/6/07, David Miller <davem@davemloft.net> wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> Date: Tue, 5 Jun 2007 18:01:41 -0700
>
> > From: Randy Dunlap <randy.dunlap@oracle.com>
> >
> > gcc doesn't like the location of the __attribute__ string here:
> > net/ipv4/tcp_probe.c:83: warning: empty declaration
> >
> > so move it to before the function and all is well.
> >
> > Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
>
> Yeah I noticed this one too and a similar fix is in
> my net-2.6 GIT tree, but thanks anyways Randy.

I'm wondering if either of you can actually load tcp_probe at present.
We had reports on dccp mailing list that dccp_probe and tcp_probe
can't load at present and produce a back trace. It appears related to
the jprobe stuff according to Arnaldo.

If the bug reporter or Arnaldo doesn't follow up on it I'll track it
down a little more later and post to correct place.

I'll also copy this change across to DCCP at sometime as well as
several others that we haven't transferred across as well.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
