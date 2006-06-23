From: Ted <txtoth@gmail.com>
Subject: Re: [RFC 3/7] NetLabel: CIPSOv4 engine
Date: Fri, 23 Jun 2006 13:48:01 -0500
Message-ID: <1151088481.2669.25.camel@localhost.localdomain>
References: <20060621194234.979661000@flek.zko.hp.com>
	 <20060621200031.589235000@flek.zko.hp.com>
	 <20060622.021223.125894633.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0102.google.com ([66.249.82.200]:40722 "EHLO
	wx-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1751917AbWFWSsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 14:48:04 -0400
Received: by wx-out-0102.google.com with SMTP id s17so534547wxc
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2006 11:48:03 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <20060622.021223.125894633.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-22 at 02:12 -0700, David Miller wrote:
> From: paul.moore@hp.com
> Date: Wed, 21 Jun 2006 15:42:38 -0400
> 
> > Add support for the Commercial IP Security Option (CIPSO) to the
> > IPv4 network stack.  CIPSO has become a de-facto standard for
> > trusted/labeled networking amongst existing Trusted Operating
> > Systems such as Trusted Solaris, HP-UX CMW, etc.  This
> > implementation is designed to be used with the NetLabel subsystem to
> > provide explicit packet labeling to LSM developers.
> 
> The thing that concerns me most about CIPSO is that even once users
> migrate to a more SELINUX native approach from this CIPSO stuff, the
> CIPSO code, it's bloat, and it's maintainence burdon will remain.
> 
> It's easy to put stuff it, it's impossible to take stuff out even
> once it's largely unused by even it's original target audience.
> 
> And that's what I see happening here.
> 
> This is why, to be perfectly honest with you, I'd much rather
> something like this stay out-of-tree and people are strongly
> encouraged to use the more native stuff under Linux.
> 

Realistically customers most likely to adopt use of SELinux are going to
be ones that currently use other trusted OSs such as TSOL and HP-UX CMW.
These users are unlikely to take an all (SELinux) or nothing approach.
Also they are more than likely customers who will want a fully
configured and supported distribution as opposed to one they'd have to
patch themselves.  With these points in mind I think CIPSO as a
integrated interoperability mechanism is critical. FYI, over the last
couple of weeks I've validated the interoperability of the CIPSO
inplementation with TSOL and HP-UX CMW.

Ted

> --
> redhat-lspp mailing list
> redhat-lspp@redhat.com
> https://www.redhat.com/mailman/listinfo/redhat-lspp

