From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: rtnetlink explicit flags setting
Date: Fri, 27 May 2005 21:12:29 -0400
Message-ID: <1117242749.6251.15.camel@localhost.localdomain>
References: <1117197157.6688.24.camel@localhost.localdomain>
	 <20050527125010.GO15391@postel.suug.ch>
	 <1117202331.6383.39.camel@localhost.localdomain>
	 <20050527141320.GQ15391@postel.suug.ch>
	 <1117206091.6383.73.camel@localhost.localdomain>
	 <20050527151913.GA15391@postel.suug.ch>
	 <1117209466.6383.106.camel@localhost.localdomain>
	 <20050527165935.GC15391@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050527165935.GC15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-27-05 at 18:59 +0200, Thomas Graf wrote:

> I took your patch, converted it to use NLMSG_NEW and finished
> converting all the modules that you started. 

Thats the patchset 1/2 and 2/2, correct?

> Yet unconverted
> are: netfilter, net/sched/ tcp_diag, xfrm, kernel/audit.
> 

I didnt find any issues with these as far as PID extrapolation.

> I also fixed some uses of NL_CREDS() to fetch the pid for
> message generation which is wrong. Various dumping procedures
> did not set the multi flag at all, I fixed all of them.
> 
> Do not apply these patches yet, they're way too intrusive

Do you mean the two patches? Those looked fine to me;
i.e its mostly the patch i posted this morning with the new Macros, no?

cheers,
jamal
