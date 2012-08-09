From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH] ipv4: tcp: security_sk_alloc() needed for unicast_sock
Date: Thu, 9 Aug 2012 12:09:00 -0400
Message-ID: <CAHC9VhTD17py3tozogz1aoHWMNV4aFV1fy44UO7++YM1rECpZg@mail.gmail.com>
References: <50215A7E.8000701@linaro.org>
	<1695034.0lrQgQPOMT@sifl>
	<1344523833.28967.996.camel@edumazet-glaptop>
	<5799181.tjlnF0gIh2@sifl>
	<1344526608.28967.1092.camel@edumazet-glaptop>
	<CACLa4ptTfMzvhYk7_DaUJd-9u406FXf2CUHjn1mQrPDa4fFW4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Casey Schaufler <casey@schaufler-ca.com>,
	John Stultz <johnstul@us.ibm.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	lkml <linux-kernel@vger.kernel.org>,
	James Morris <james.l.morris@oracle.com>,
	selinux@tycho.nsa.gov, john.johansen@canonical.com,
	LSM <linux-security-module@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Paris <eparis@parisplace.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CACLa4ptTfMzvhYk7_DaUJd-9u406FXf2CUHjn1mQrPDa4fFW4w@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 9, 2012 at 12:05 PM, Eric Paris <eparis@parisplace.org> wrote:
> Paul, are you looking into this?  This is a bandaide, not a fix....

Yep, I mentioned this a few times in the other thread.  The problem is
there is not going to be an easy fix for the labeling so I'd rather we
see this patch, or something like it, go in now to resolve the kernel
panic, and fix the labeling later.

-- 
paul moore
www.paul-moore.com
