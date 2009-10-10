From: Greg KH <greg@kroah.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Sat, 10 Oct 2009 14:06:12 -0700
Message-ID: <20091010210612.GA1927@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009210909.GA9836@auslistsprd01.us.dell.com> <20091009194401.036da080@nehalam> <20091010044056.GA5350@mock.linuxdev.us.dell.com> <20091010113219.3136fb8b@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Domsch <Matt_Domsch@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, Narendra_K@dell.com,
	jordan_hargrave@dell.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091010113219.3136fb8b@s6510>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 10, 2009 at 11:32:19AM -0700, Stephen Hemminger wrote:
> 
> BTW, for our distro, we are looking into device renaming based on PCI slot
> because that is what router OS's do. Customers expect if they replace the card
> in slot 0, it will come back with the same name.  This is not what server
> customers expect.

If your bios exposes the PCI slots to userspace (through the proper ACPI
namespace), doing this type of naming should be trivial with some simple
udev rules, no additional kernel infrastructure is needed.

thanks,

greg k-h
