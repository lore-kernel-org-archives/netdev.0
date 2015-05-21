From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [RESEND][PATCH] Bluetooth: Make request workqueue freezable
Date: Thu, 21 May 2015 10:18:08 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1505211009240.1397-100000@iolanthe.rowland.org>
References: <s5hoalegla7.wl-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Laura Abbott <labbott@redhat.com>,
	Oliver Neukum <oneukum@suse.com>,
	Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Laura Abbott <labbott@fedoraproject.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	"bluez mailin list (linux-bluetooth@vger.kernel.org)"
	<linux-bluetooth@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	USB list <linux-usb@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Takashi Iwai <tiwai@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <s5hoalegla7.wl-tiwai@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 21 May 2015, Takashi Iwai wrote:

> Then avoiding the failed firmware is no solution, indeed.
> If it's a new probe, it should be never executed during resume.

Can you expand this comment?  What's wrong with probing during resume?

The USB stack does carry out probes during resume under certain
circumstances.  A driver lacking a reset_resume callback is one of
those circumstances.

Alan Stern
