From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH for-next 00/14][PULL request] Mellanox mlx5 core driver
 updates 2016-10-25
Date: Sun, 30 Oct 2016 12:02:28 -0400 (EDT)
Message-ID: <20161030.120228.1925848506424477810.davem@davemloft.net>
References: <1477407617-20745-1-git-send-email-saeedm@mellanox.com>
        <20161028.135309.1712496950641242201.davem@davemloft.net>
        <CALzJLG8cN0VUiTHDdkgibObA970UsAP+E7E=DSgY1RKNefSyzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALzJLG8cN0VUiTHDdkgibObA970UsAP+E7E=DSgY1RKNefSyzA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Date: Sun, 30 Oct 2016 11:59:57 +0200

> On Fri, Oct 28, 2016 at 7:53 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>>
>> I really disalike pull requests of this form.
>>
>> You add lots of datastructures and helper functions but no actual
>> users of these facilities to the driver.
>>
>> Do this instead:
>>
>>         1) Add TSAR infrastructure
>>         2) Add use of TSAR facilities to the driver
>>
>> That's one pull request.
>>
>> I don't care if this is hard, or if there are entanglements with
>> Infiniband or whatever, you must submit changes in this manner.
>>
> 
> It is not hard, it is just not right,  we have lots of IB and ETH
> features that we would like to submit in the same kernel cycle,
> with your suggestion I will have to almost submit every feature (core
> infrastructure and netdev/RDMA usage)
> to you and Doug.

Nobody can properly review an API addition without seeing how that
API is _USED_.

This is a simple fundamental fact.

And I'm not pulling in code that can't be reviewed properly.

Also, so many times people have added new junk to drivers and months
later never added the users of that new code and interfaces.

Forcing you to provide the use with the API addition makes sure that
it is absolutely impossible for that to happen.

Whatever issues you think prevent this are your issues, not mine.  I
want high quality submissions that can be properly reviewed, and you
have to find a way to satisfy that requirement.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
