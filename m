From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH -next v3 1/2] device property: Return -ENXIO if there is
 no suitable FW interface
Date: Thu, 27 Aug 2015 10:32:07 -0500
Message-ID: <55DF2D77.6050006@arm.com>
References: <1440646025-18999-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	"tony@atomide.com" <tony@atomide.com>
To: Guenter Roeck <linux@roeck-us.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440646025-18999-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/26/2015 10:27 PM, Guenter Roeck wrote:
> Return -ENXIO if device property array access functions don't find
> a suitable firmware interface.
>
> This lets drivers decide if they should use available platform data
> instead.

Works fine on an ACPI based ARM system.

Thanks, for taking care of this.

Tested-by: Jeremy Linton <jeremy.linton@arm.com>
