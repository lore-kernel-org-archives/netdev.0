From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [2.6 patch] net/sched/: possible cleanups
Date: Wed, 15 Dec 2004 12:27:41 +0100
Message-ID: <20041215112741.GJ8493@postel.suug.ch>
References: <20041215012754.GH12937@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20041215012754.GH12937@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Adrian Bunk <20041215012754.GH12937@stusta.de> 2004-12-15 02:27

> -extern int tcf_act_police_locate(struct rtattr *rta, struct rtattr *est,struct tc_action *,int , int );
> -extern int tcf_act_police_dump(struct sk_buff *, struct tc_action *, int, int);
> -extern int tcf_act_police(struct sk_buff **skb, struct tc_action *a);

This looks like a police compat API for action policers but I think it's
fine, Jamal?

The other changes all make sense to me.
