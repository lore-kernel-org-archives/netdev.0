From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: wireless: recap of current issues (configuration)
Date: Sat, 14 Jan 2006 17:07:01 -0500
Message-ID: <43C97605.9030907@pobox.com>
References: <20060113195723.GB16166@tuxdriver.com> <20060113212605.GD16166@tuxdriver.com> <20060113213011.GE16166@tuxdriver.com> <20060113221935.GJ16166@tuxdriver.com> <1137191522.2520.63.camel@localhost> <20060114011726.GA19950@shaftnet.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751321AbWANWHP@vger.kernel.org>
To: Stuffed Crust <pizza@shaftnet.org>
In-Reply-To: <20060114011726.GA19950@shaftnet.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stuffed Crust wrote:
> The hardware knows what frequencies it supports.  Unfortunately this has 
> to be a somewhat dynamic thing, as this is often not queryable until the 
> device firmware is up and running.  
> 
> This can be accomplished by passing a static table to the 
> register_wiphy_device() call (or perhaps via a struct wiphy_dev 
> parameter) or through a more explicit, dynamic interface like:
> 
>   wiphy_register_supported_frequency(hw, 2412). 


For completely programmable hardware, the stack should interact with a 
module like ieee80211_geo, to help ensure the hardware stays within 
legal limits.

	Jeff
