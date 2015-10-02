From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [RFC PATCH 3/3] net: dsa: exit probe if no switch were found
Date: Fri, 2 Oct 2015 14:10:54 +0200
Message-ID: <560E744E.4010502@baylibre.com>
References: <560B9B7C.9080406@baylibre.com> <560D50E4.6040400@baylibre.com>
 <20151001163257.GQ20219@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151001163257.GQ20219@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/01/2015 06:32 PM, Andrew Lunn wrote:
> On Thu, Oct 01, 2015 at 05:27:32PM +0200, Neil Armstrong wrote:
>> On 09/30/2015 10:21 AM, Neil Armstrong wrote:
>>> If no switch were found in dsa_setup_dst, return -ENODEV and
>>> exit the dsa_probe cleanly.
> 
> ...
>  
>> Couldn't we use the probe defer mechanism here ? (until complete rework is done)
> 
> Hi Neil
> 
> I was thinking the same last night. We know the switch should be
> there, otherwise it would not be in DT. So returning -EPROBE_DEFER
> would be valid.
> 
>       Andrew
> 
Hi,

It makes sens but does a module insertion triggers the differed probe ?

I will still post this change in a next set of patch.

Neil
