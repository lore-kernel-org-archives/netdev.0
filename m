From: "Catherine Zhang" <czhang.us@gmail.com>
Subject: Re: updated [Patch 1/1] AF_UNIX Datagram getpeersec
Date: Sun, 18 Jun 2006 00:46:48 -0400
Message-ID: <ebe353740606172146ob1e8cefpe489c58b1fb07ba0@mail.gmail.com>
References: <20060617035440.GA28169@jiayuguan.watson.ibm.com>
	 <20060616211603.14547a1d@localhost.localdomain>
	 <Pine.LNX.4.64.0606171151320.16944@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@osdl.org>,
	"Catherine Zhang" <cxzhang@watson.ibm.com>, netdev@vger.kernel.org,
	davem@davemloft.net, jmorris@redhat.com, chrisw@osdl.org,
	herbert@gondor.apana.org.au, sds@tycho.nsa.gov,
	tjaeger@cse.psu.edu, akpm@osdl.org, latten@austin.ibm.com,
	sergeh@us.ibm.com, gcwilson@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0102.google.com ([66.249.82.205]:1741 "EHLO
	wx-out-0102.google.com") by vger.kernel.org with ESMTP
	id S932086AbWFREqt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jun 2006 00:46:49 -0400
Received: by wx-out-0102.google.com with SMTP id h28so626876wxd
        for <netdev@vger.kernel.org>; Sat, 17 Jun 2006 21:46:49 -0700 (PDT)
To: "James Morris" <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0606171151320.16944@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/17/06, James Morris <jmorris@namei.org> wrote:
> On Fri, 16 Jun 2006, Stephen Hemminger wrote:
>
> > This is so short, it would make sense to put it in scm.h
> > and why not have it return the value instead of call by reference?
> > Same goes for selinux_get_inode_sid
>
> Actually, all of the SELinux API functions are like this, and I'm not sure
> why for void return methods (it's a good idea when they return errnos).
>

Yes, the reason I used void return method is consistency with the
remaining SELinux API functions.

> Once this area has settled down (post 2.6.18), I'm planning to do some
> cleanups for this API anyway, and can fix these all at the same time.
>

OK.

Thanks,
Catherine
