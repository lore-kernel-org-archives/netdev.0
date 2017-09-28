From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 2/4] ipv4: Remove the 'publish' logic in
 tcp_fastopen_init_key_once
Date: Thu, 28 Sep 2017 10:47:48 -0700 (PDT)
Message-ID: <20170928.104748.602016526967872454.davem@davemloft.net>
References: <1506483343-11544-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
        <1506483343-11544-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, edumazet@google.com, weiwan@google.com,
        lucab@debian.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506483343-11544-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Wed, 27 Sep 2017 11:35:41 +0800

> The 'publish' logic is not necessary after commit dfea2aa65424 ("tcp:
> Do not call tcp_fastopen_reset_cipher from interrupt context"), because
> in tcp_fastopen_cookie_gen，it wouldn't call tcp_fastopen_init_key_once.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied.
