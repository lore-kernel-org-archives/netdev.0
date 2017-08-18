From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH V5 net-next 01/21] net-next/hinic: Initialize hw
 interface
Date: Thu, 17 Aug 2017 17:42:05 -0700
Message-ID: <20170817174205.6a1b12b6@xeon-e3>
References: <cover.1502970631.git.aviad.krawczyk@huawei.com>
        <544e2ccb65ea083d9b736df6ea0bdd59353da815.1502970631.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <bc.y@huawei.com>,
        <victor.gissin@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <544e2ccb65ea083d9b736df6ea0bdd59353da815.1502970631.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Aug 2017 19:52:42 +0800
Aviad Krawczyk <aviad.krawczyk@huawei.com> wrote:

> +
> +/**
> + * init_pfhwdev - Initialize the extended components of PF
> + * @pfhwdev: the HW device for PF
> + *
> + * Return 0 - success, negative - failure
> + **/
> +static int init_pfhwdev(struct hinic_pfhwdev *pfhwdev)
> +{
> +	/* Initialize PF HW device extended components */
> +	return 0;
> +}
> +
> +/**
> + * free_pfhwdev - Free the extended components of PF
> + * @pfhwdev: the HW device for PF
> + **/
> +static void free_pfhwdev(struct hinic_pfhwdev *pfhwdev)
> +{
> +}

Please drop these functions, they do nothing and are not used
as stubs in any operations table.
