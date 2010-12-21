From: nvishwan@codeaurora.org
Subject: Re: [PATCH] msm: rmnet: msm rmnet smd virtual ethernet driver
Date: Tue, 21 Dec 2010 15:44:52 -0800 (PST)
Message-ID: <d141676494ae8979d4b32a337c9dba38.squirrel@www.codeaurora.org>
References: <1292437866-11652-1-git-send-email-nvishwan@codeaurora.org>
    <20101215134107.0354c0c3@nehalam>
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
In-Reply-To: <20101215134107.0354c0c3@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Wed, 15 Dec 2010 10:31:06 -0800
> Niranjana Vishwanathapura <nvishwan@codeaurora.org> wrote:
>
>> +static struct net_device_stats *rmnet_get_stats(struct net_device *dev)
>> +{
>> +	struct rmnet_private *p = netdev_priv(dev);
>> +	return &p->stats;
>> +}
>> +
>
> Just use dev->stats and this function would no longer be needed.
>
> --
>

This function will be a function pointer (ndo_get_stats) in net_device_ops
structure.
