From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 6/6] tcp_metrics: Use a single hash table for
 all network namespaces.
Date: Mon, 09 Mar 2015 11:43:17 -0700
Message-ID: <1425926597.8261.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	 <CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	 <87d25hrv9m.fsf@x220.int.ebiederm.org>
	 <20150219.144929.1003473344851168804.davem@davemloft.net>
	 <87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	 <8761aayqdd.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	netdev@vger.kernel.org, stephen@networkplumber.org,
	nicolas.dichtel@6wind.com, roopa@cumulusnetworks.com,
	hannes@stressinduktion.org, ddutt@cumulusnetworks.com,
	vipin@cumulusnetworks.com, shmulik.ladkani@gmail.com,
	dsahern@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:42489 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449AbbCISnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 14:43:19 -0400
Received: by iecvy18 with SMTP id vy18so41809009iec.9
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 11:43:19 -0700 (PDT)
In-Reply-To: <8761aayqdd.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-09 at 13:31 -0500, Eric W. Biederman wrote:

>  
> +static struct tcpm_hash_bucket	*tcp_metrics_hash;
> +static unsigned int		tcp_metrics_hash_log;

static struct tcpm_hash_bucket *tcp_metrics_hash __read_mostly;
static unsigned int            tcp_metrics_hash_log __read_mostly;


> +
>  static DEFINE_SPINLOCK(tcp_metrics_lock);
