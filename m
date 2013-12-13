From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v3 1/6] net_sched: remove get_stats from tc_action_ops
Date: Fri, 13 Dec 2013 10:21:42 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7489@saturn3.aculab.com>
References: <1386913673-8210-1-git-send-email-xiyou.wangcong@gmail.com> <1386913673-8210-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Jamal Hadi Salim" <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Cong Wang" <xiyou.wangcong@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:60505 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752188Ab3LMKWv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 05:22:51 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 02978-01 for <netdev@vger.kernel.org>;
 Fri, 13 Dec 2013 10:22:48 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1386913673-8210-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Cong Wang
> 
> It is not used.
...
> --- a/include/net/act_api.h
> +++ b/include/net/act_api.h
> @@ -72,7 +72,6 @@ struct tc_action_ops {
>  	__u32 	capab;  /* capabilities includes 4 bit version */
>  	struct module		*owner;
>  	int     (*act)(struct sk_buff *, const struct tc_action *, struct tcf_result *);
> -	int     (*get_stats)(struct sk_buff *, struct tc_action *);
>  	int     (*dump)(struct sk_buff *, struct tc_action *, int, int);
>  	int     (*cleanup)(struct tc_action *, int bind);
>  	int     (*lookup)(struct tc_action *, u32);

Deleting a field out of the middle of a list of function pointers
seems dangerous.

	David
