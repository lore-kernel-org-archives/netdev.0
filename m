From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] sky2: Add module parameter for passing the MAC address
Date: Wed, 5 Aug 2015 09:40:57 -0700
Message-ID: <20150805094057.59260077@urahara>
References: <1438789854-29194-1-git-send-email-Liviu.Dudau@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <mlindner@marvell.com>,
	Ryan Harkin <ryan.harkin@linaro.org>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Liviu Dudau <Liviu.Dudau@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438789854-29194-1-git-send-email-Liviu.Dudau@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed,  5 Aug 2015 16:50:54 +0100
Liviu Dudau <Liviu.Dudau@arm.com> wrote:

> For designs where EEPROMs are not connected to PCI Yukon2
> chips we need to get the MAC address from the firmware.
> Add a module parameter called 'mac_address' for this. It
> will be used if no DT node can be found and the B2_MAC
> register holds an invalid value.
> 
> Signed-off-by: Liviu Dudau <Liviu.Dudau@arm.com>

Yes, I can see that this can be a real problem, and other drivers
solve the problem. The standard method is to assign a random mac address
(and then let scripts overwrite) rather than introducing module parameter.
Module parameters are discouraged because they are device specific.

 
