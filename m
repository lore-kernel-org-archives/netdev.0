From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH-next v2 3/4] net/sched: make sch_blackhole.c explicitly non-modular
Date: Wed, 7 Oct 2015 14:47:10 -0700
Message-ID: <CAHA+R7PgVBptnzzcWFW+9bp9UL40e+V+4K8PJjrF-KzeFQodQw@mail.gmail.com>
References: <1444253266-22012-1-git-send-email-paul.gortmaker@windriver.com>
	<1444253266-22012-4-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:35771 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755151AbbJGVrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 17:47:11 -0400
Received: by ykdz138 with SMTP id z138so31738674ykd.2
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 14:47:11 -0700 (PDT)
In-Reply-To: <1444253266-22012-4-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 7, 2015 at 2:27 PM, Paul Gortmaker
<paul.gortmaker@windriver.com> wrote:
> The Kconfig currently controlling compilation of this code is:
>
> net/sched/Kconfig:menuconfig NET_SCHED
> net/sched/Kconfig:      bool "QoS and/or fair queueing"
>
> ...meaning that it currently is not being built as a module by anyone.

Is there any reason why sch_blackhole can't be a module like
other qdisc's?

If not, I'd rather making it be a module. It is small but not often used.
