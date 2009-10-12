From: Greg KH <greg@kroah.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Sun, 11 Oct 2009 20:00:08 -0700
Message-ID: <20091012030008.GA8436@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009210909.GA9836@auslistsprd01.us.dell.com> <20091009194401.036da080@nehalam> <20091010044056.GA5350@mock.linuxdev.us.dell.com> <20091010052308.GA12458@kroah.com> <7e84ed60910111410g52ffd52bjec62576570d4b460@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, jordan_hargrave@dell.com
To: Rob Townley <rob.townley@gmail.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <7e84ed60910111410g52ffd52bjec62576570d4b460@mail.gmail.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 11, 2009 at 04:10:03PM -0500, Rob Townley wrote:
> So when an add-in PCI NIC has a lower MAC than the motherboard NICs,
> the add-in cards will come before the motherboard NICs.   i don't like it.

Huh?  Have you used the MAC persistant rules?  If you add a new card,
what does it pick for it?

> But please whatever is done, make sure ping and tracert still works when
> telling it to use a ethX source interface:
> 
> eth0 = 4.3.2.8, the default gateway is thru eth1.
> ping -I eth0 208.67.222.222              FAILS
> ping -I 4.3.2.8 208.67.222.222          WORKS
> tracert -i eth0 -I 208.67.222.222        FAILS
> tracert -s 4.3.2.8 -I 208.67.222.222   WORKS
> tracert -i eth0 208.67.222.222           FAILS
> tracert -s 4.3.2.8 208.67.222.222      WORKS

Again, is what we currently have broken?  I am confused as to what this
is referring to.

greg k-h
