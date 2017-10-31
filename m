From: Stefano Brivio <sbrivio@redhat.com>
Subject: Re: [iproute PATCH 3/3] ss: Fix width calculations when Netid or
 State columns are missing
Date: Tue, 31 Oct 2017 18:02:11 +0100
Message-ID: <20171031180211.2bd749bf@elisabeth>
References: <cover.1509307616.git.sbrivio@redhat.com>
        <e392e5bfa950ab752000ce40e7a43c3da03b1a53.1509307616.git.sbrivio@redhat.com>
        <20171031175506.6a7ff560@shemminger-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59433 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753585AbdJaRCT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 13:02:19 -0400
In-Reply-To: <20171031175506.6a7ff560@shemminger-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Oct 2017 17:55:06 +0100
Stephen Hemminger <stephen@networkplumber.org> wrote:

> On Sun, 29 Oct 2017 21:22:34 +0100
> Stefano Brivio <sbrivio@redhat.com> wrote:
> 
> > +	addrp_width -= netid_width + 1 * !!netid_width;
> > +	addrp_width -= state_width + 1 * !!state_width;  
> 
> Doing !! here is being too bit tricky for code that is not performance sensitive.
> Just use an if statement or ? :

Sure.

> > @@ -4373,6 +4374,8 @@ int main(int argc, char *argv[])
> >  			netid_width++;
> >  		else if (state_width)
> >  			state_width++;
> > +		else
> > +			odd_width_pad=" ";  
> 
> Missing whitespace.

Oops. Thanks. I'll fix both issues in v2.

-- 
Stefano
