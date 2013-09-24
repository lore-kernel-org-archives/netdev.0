From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] Allow userspace code to use flag IFA_F_SECONDARY to
 specify an ip address to be primary or secondary ip on an interface
Date: Tue, 24 Sep 2013 12:21:01 -0700
Message-ID: <20130924122101.6912dde0@nehalam.linuxnetplumber.net>
References: <1380046281-6012-1-git-send-email-vincent.mc.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380046281-6012-1-git-send-email-vincent.mc.li@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Sep 2013 11:11:21 -0700
Vincent Li <vincent.mc.li@gmail.com> wrote:

> -	ifa->ifa_flags &= ~IFA_F_SECONDARY;
>  	last_primary = &in_dev->ifa_list;
>  
> +	if((*last_primary) == NULL)


Minor nit, paren's here are unnecessary
