From: Vincent Sanders <vincent.sanders@collabora.co.uk>
Subject: Re: AF_BUS socket address family
Date: Sat, 30 Jun 2012 00:42:30 +0100
Message-ID: <20120629234230.GA11480@kyllikki.org>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
 <20120629.153656.1141845894730637434.davem@davemloft.net>
 <20120629231236.GA28593@mail.collabora.co.uk>
 <20120629.161821.948325645333976311.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120629.161821.948325645333976311.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 29, 2012 at 04:18:21PM -0700, David Miller wrote:
> From: Vincent Sanders <vincent.sanders@collabora.co.uk>
> Date: Sat, 30 Jun 2012 00:12:37 +0100
> 
> > I had hoped you would have at least read the opening list where I
> > outlined the underlying features which explain why none of the
> > existing IPC match the requirements.
> 
> I had hoped that you had read the part we told you last time where
> we explained why multicast and "reliable delivery" are fundamentally
> incompatible attributes.
> 

I do not beleive we indicated reliable delivery, mearly ordered and
idempotent. eitehr everyone gets the message in the same order or
noone gets it.

> We are not creating a full address family in the kernel which exists
> for one, and only one, specific and difficult user.

Basically you are indicating you would be completely opposed to any
mechanism involving D-Bus IPC and the kernel? 

Is there were a way to convince you that this is of real value to a
great many of the users of Linux systems in use today. I can assert
with some confidence that there are many, many more users of D-Bus IPC
than there are for several of the other address families that are
present within the kernel already. 

The current users are suffering from the issues outlined in my
introductory mail all the time. These issues are caused by emulating an
IPC system over AF_UNIX in userspace.

All we are trying to do is make things better for our users, is there
a way to do that which will satisfy you technically and them? Honestly
I am just looking for a viable solution here.

-- 
Regards Vincent
