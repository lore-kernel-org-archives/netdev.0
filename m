From: Ted <txtoth@gmail.com>
Subject: Re: [RFC 3/7] NetLabel: CIPSOv4 engine
Date: Fri, 23 Jun 2006 15:34:17 -0500
Message-ID: <1151094857.2669.51.camel@localhost.localdomain>
References: <20060621200031.589235000@flek.zko.hp.com>
	 <20060622.021223.125894633.davem@davemloft.net>
	 <1151088481.2669.25.camel@localhost.localdomain>
	 <20060623.131512.21593290.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0102.google.com ([66.249.82.198]:57162 "EHLO
	wx-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1752033AbWFWUeU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 16:34:20 -0400
Received: by wx-out-0102.google.com with SMTP id s17so554754wxc
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2006 13:34:19 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <20060623.131512.21593290.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-06-23 at 13:15 -0700, David Miller wrote:
> From: Ted <txtoth@gmail.com>
> Date: Fri, 23 Jun 2006 13:48:01 -0500
> 
> > Realistically customers most likely to adopt use of SELinux are
> > going to be ones that currently use other trusted OSs such as TSOL
> > and HP-UX CMW.
> 
> Every single user who installs a modern distribution these days likely
> gets SELINUX enabled by default, and are therefore adopters of
> SELINUX.  That's a lot of people.
> 
> The number of people with existing CIPSO infrastructure are miniscule
> in comparison.
> 

I think that except those who currently use and understand trusted OSs
users will change SELinux to permissive mode because they won't have the
expertise to deal with policy issues. 

> Please do not even imply that CIPSO use is anything but fringe in the
> grand scheme of things.  It most certainly is.  And it will be
> replaced by IPSEC based labelling, that is a fact.  If people cannot
> move over to IPSEC labelling simply because their HPUX/TSOL doesn't
> support it, I'm perfectly happy for those users to stick with HPUX and
> TSOL.  A lot of people think Linux should try to be everything for
> everybody, I'm not one of those people :-)
> 

I can guarantee that initially SELinux adoption will be by those running
trusted OSs and they will want their systems to be able to interoperate
at level. The idea that IPSEC will fill this need in the near term is
just not realistic.

> For CIPSO we eat a non-trivial maintainence and bloat cost in order to
> support legacy stuff for this relatively tiny group of potential
> users.
> 
> I'd rather pay the bloat and development costs on something forward
> thinking like IPSEC labelling.  Something people will actually be
> using years from now, rather than a dying technology that few people
> (relatively speaking) use as it is.
> 
> Finally, even if CIPSO is something we want to put in, don't worry
> about it as there's still time to discuss things.  A couple days
> before the merge window of 2.6.18 development closes is not the time
> to be submitting half-finished work and expecting it to be integrated.
> If 2.6.18 integration is what the submitter desires, they should have
> finished their work and started this review process weeks if not
> months ago.

