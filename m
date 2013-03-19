From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] use xfrm direction when lookup policy
Date: Tue, 19 Mar 2013 09:27:35 -0400 (EDT)
Message-ID: <20130319.092735.322670260944589079.davem@davemloft.net>
References: <1363696786-11128-1-git-send-email-baker.zhang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	baker.zhang@gmail.com
To: baker.kernel@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363696786-11128-1-git-send-email-baker.zhang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baker Zhang <baker.kernel@gmail.com>
Date: Tue, 19 Mar 2013 20:39:46 +0800

> +static inline int flow_to_policy_dir(int dir)

Please do not use inline in foo.c files, just let the compiler decide
whether inlining is a good idea or not.

Thanks.
