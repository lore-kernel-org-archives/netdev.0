From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH]  Break 'budget' dependency on netdev_max_backlog.
Date: Tue, 22 Oct 2002 20:47:19 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210222033210.24323-100000@shell.cyberus.ca>
References: <3DB42A90.1030709@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DB42A90.1030709@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Mon, 21 Oct 2002, Ben Greear wrote:

> jamal wrote:
> > Patch looks fine except for the 300 number. What are you smoking?
> > Please retain the original value.
>
> The original value was 300, what do you want it to be?
>

Ok, i take back what i said then. Your patch is not that useful.
For some reason i thought you were introducing NET_CORE_DEV_WEIGHT
which happens to already exist with default value of 64.
The value you put out MUST be the same as netdev_max_backlog in order
to be fair to non-NAPI devices.
Any change to one must be reflected to the other. So a useful patch
will try to shadow NET_CORE_MAX_BACKLOG to that value and allow only
changes to happen to NET_CORE_MAX_BACKLOG; i.e no need for two separate
parameters.

cheers,
jamal
