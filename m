From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH 1/2] Bluetooth: Add reset_resume function
Date: Tue, 02 Jun 2015 09:47:50 +0200
Message-ID: <1433231270.1708.5.camel@suse.com>
References: <1433207682-15064-1-git-send-email-labbott@fedoraproject.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	Takashi Iwai <tiwai@suse.de>, linux-bluetooth@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	USB list <linux-usb@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Laura Abbott <labbott@fedoraproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433207682-15064-1-git-send-email-labbott@fedoraproject.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-06-01 at 18:14 -0700, Laura Abbott wrote:
> Bluetooth devices off of some buses such as USB may lose power across
> suspend/resume. When this happens, drivers may need to have the setup
> function called again and behave differently than a cold power on.

Yes, but what is the point? We use reset_resume() to retain
some features of a device across a loss of power.
If power is lost, all settings are gone and all connections
are broken. So what is the difference compared to a plug out/in
cycle?

	Regards
		Oliver
