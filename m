From: nvishwan@codeaurora.org
Subject: Re: [PATCH] msm: rmnet: msm rmnet smd virtual ethernet driver
Date: Tue, 21 Dec 2010 15:45:12 -0800 (PST)
Message-ID: <9eecc86d79182bb887f241f7367de068.squirrel@www.codeaurora.org>
References: <1292437866-11652-1-git-send-email-nvishwan@codeaurora.org>
    <20101215134135.51df5a7f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Niranjana Vishwanathapura" <nvishwan@codeaurora.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-msm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	"Brian Swetland" <swetland@google.com>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101215134135.51df5a7f@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Wed, 15 Dec 2010 10:31:06 -0800
> Niranjana Vishwanathapura <nvishwan@codeaurora.org> wrote:
>
>> +
>> +static void rmnet_tx_timeout(struct net_device *dev)
>> +{
>> +	pr_info("rmnet_tx_timeout()\n");
>> +}
>
> The purpose of having a tx_timeout is to clear the pending
> request.
>
> --
>

Currently, there is no mechanism to clear the transaction.  This message
is helpful in identifying the issue and fixing it.
