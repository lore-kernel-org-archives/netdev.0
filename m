From: jamal <hadi@cyberus.ca>
Subject: Re: [2.6 patch] net/sched/: possible cleanups
Date: 15 Dec 2004 09:03:12 -0500
Message-ID: <1103119392.1078.67.camel@jzny.localdomain>
References: <20041215012754.GH12937@stusta.de>
	 <20041215112741.GJ8493@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041215112741.GJ8493@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This is fine. The new architecture doesnt require classifiers explicitly
call those function. Rest also looks fine to me. Good effort Adrian.

cheers,
jamal

On Wed, 2004-12-15 at 06:27, Thomas Graf wrote:
> * Adrian Bunk <20041215012754.GH12937@stusta.de> 2004-12-15 02:27
> 
> > -extern int tcf_act_police_locate(struct rtattr *rta, struct rtattr *est,struct tc_action *,int , int );
> > -extern int tcf_act_police_dump(struct sk_buff *, struct tc_action *, int, int);
> > -extern int tcf_act_police(struct sk_buff **skb, struct tc_action *a);
> 
> This looks like a police compat API for action policers but I think it's
> fine, Jamal?
> 
> The other changes all make sense to me.
> 
