From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 1/1] hv_netvsc: Fix a bug in netvsc_start_xmit()
Date: Tue, 28 Apr 2015 21:27:08 +0300
Message-ID: <553FD0FC.3090704@cogentembedded.com>
References: <1430183690-24198-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: "K. Y. Srinivasan" <kys@microsoft.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
	jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430183690-24198-1-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04/28/2015 04:14 AM, K. Y. Srinivasan wrote:

> Commit commit b08cc79155fc26d0d112b1470d1ece5034651a4b eliminated memory

    One "commit" is enough. :-)
    And please also specify that commit's summary in parens.

> allocation in the packet send path. This commit introduced a bug since it
> did not account for the case if the skb was cloned. Fix this bug by
> using the pre-reserved head room only if the skb is not cloned.

> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

[...]

WBR, Sergei
