From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH] device property: Don't overwrite addr when failing in
 device_get_mac_address
Date: Fri, 4 Sep 2015 09:03:00 -0500
Message-ID: <55E9A494.5000108@arm.com>
References: <1441321190-25631-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Julien Grall <julien.grall@citrix.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441321190-25631-1-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/03/2015 05:59 PM, Julien Grall wrote:
> The function device_get_mac_address is trying different property names
> in order to get the mac address. To check the return value, the variable
> addr (which contain the buffer pass by the caller) will be re-used. This
> means that if the previous property is not found, the next property will
> be read using a NULL buffer.

Thanks for catching that! I checked the OF version to see if it has the 
same problem, but of course it doesn't because I added the logic to pass 
the buffer into the routine.

Reviewed-by: Jeremy Linton <jeremy.linton@arm.com>
