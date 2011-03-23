From: Pat Kane <pekane52@gmail.com>
Subject: Re: [PATCH v2] net/unix: Add secdata to unix_stream msgs
Date: Wed, 23 Mar 2011 15:23:35 -0500
Message-ID: <AANLkTik55CAKfU5v4PE87h26vwAMy8vV7rhMmu9EA19B@mail.gmail.com>
References: <1300840717-4413-1-git-send-email-pekane52@gmail.com>
	<20110322.193206.28821045.davem@davemloft.net>
	<1300895847.28871.13.camel@unknown001a4b0c2895>
	<4D8A1BB4.4030709@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Paris <eparis@redhat.com>, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	cxzhang@watson.ibm.com, sds@tycho.nsa.gov, jmorris@namei.org,
	eparis@parisplace.org, paul.moore@hp.com,
	LSM <linux-security-module@vger.kernel.org>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4D8A1BB4.4030709@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  >> On Tue, 2011-03-22 at 19:32 -0700, David Miller wrote:
  >>> The SELINUX hook implementations even have "_dgram()" in their names.

The LSM hook that I am having problems with, and that the patch fixes
is  "secid_to_secctx()"  not "socket_getpeersec_dgram()".


Pat
---
