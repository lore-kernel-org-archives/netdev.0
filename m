From: David Zeuthen <david@fubar.dk>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Sun, 11 Oct 2009 12:40:18 -0400
Message-ID: <1255279218.25232.4.camel@localhost.localdomain>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
	 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
	 <20091009210909.GA9836@auslistsprd01.us.dell.com>
	 <20091009194401.036da080@nehalam>
	 <20091010044056.GA5350@mock.linuxdev.us.dell.com>
	 <20091010052308.GA12458@kroah.com>
	 <20091010124731.GA17218@mock.linuxdev.us.dell.com>
	 <20091010162518.GA30354@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, jordan_hargrave@dell.com
To: Greg KH <greg@kroah.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20091010162518.GA30354@kroah.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2009-10-10 at 09:25 -0700, Greg KH wrote:
> Ok, but that way can be done in userspace, without the need for this
> char device, right?

It might actually be nice to have a device file anyway since you can use
existing udev infrastructure to adjust permissions (e.g. chown it to the
netdev group) and add ACLs. This would allow running some software as an
unprivileged user instead of uid 0.

      David


