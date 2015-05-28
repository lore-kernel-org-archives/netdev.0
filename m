From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] netevent: remove automatic variable in register_netevent_notifier()
Date: Thu, 28 May 2015 17:07:53 +0300
Message-ID: <55672139.1050306@cogentembedded.com>
References: <1432807250-223365-1-git-send-email-long.wanglong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, peifeiyue@huawei.com,
	wanglong@laoqinren.net
To: Wang Long <long.wanglong@huawei.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432807250-223365-1-git-send-email-long.wanglong@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 5/28/2015 1:00 PM, Wang Long wrote:

> Remove automatic variable 'err' in register_netevent_notifier() and
> return the return value of atomic_notifier_chain_register() directly.

    s/return value/result/, in order to avoid tautology.

> Signed-off-by: Wang Long <long.wanglong@huawei.com>
[...]

WBR, Sergei
