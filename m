From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v3 2/8] net: rework setup_tc ndo op to consume
 general tc operand
Date: Wed, 17 Feb 2016 05:42:53 -0500
Message-ID: <56C44EAD.6060606@mojatatu.com>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
 <20160217051643.17139.34617.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: John Fastabend <john.fastabend@gmail.com>, jiri@resnulli.us,
	amir@vadai.me, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:37683 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161083AbcBQKmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 05:42:55 -0500
Received: by mail-ig0-f170.google.com with SMTP id 5so12337089igt.0
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 02:42:55 -0800 (PST)
In-Reply-To: <20160217051643.17139.34617.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-17 12:16 AM, John Fastabend wrote:
> This patch updates setup_tc so we can pass additional parameters into
> the ndo op in a generic way. To do this we provide structured union
> and type flag.
>
> This lets each classifier and qdisc provide its own set of attributes
> without having to add new ndo ops or grow the signature of the
> callback.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>


Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
