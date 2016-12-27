From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: Namespaceify tcp_tw_reuse knob
Date: Tue, 27 Dec 2016 12:29:44 -0500 (EST)
Message-ID: <20161227.122944.1566432083534281121.davem@davemloft.net>
References: <1482647596-25239-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        kernel@kyup.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482647596-25239-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Sun, 25 Dec 2016 14:33:16 +0800

> Different namespaces might have different requirements to reuse
> TIME-WAIT sockets for new connections. This might be required in
> cases where different namespace applications are in place which
> require TIME_WAIT socket connections to be reduced independently
> of the host.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> 
> ---
> Changes in v2:
>   - Make the commit message more clearer.

Applied.
