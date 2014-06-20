From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH net-next] hyperv: Add handler for
 RNDIS_STATUS_NETWORK_CHANGE event
Date: Fri, 20 Jun 2014 06:57:04 +0200
Message-ID: <20140620045704.GA4850@aepfle.de>
References: <1403228076-7596-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org, kys@microsoft.com,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1403228076-7596-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 19, Haiyang Zhang wrote:

> The RNDIS_STATUS_NETWORK_CHANGE event is received after the Hyper-V host
> sleep or hibernation. We refresh network at this time.

> +	char *argv[] = { "/etc/init.d/network", "restart", NULL };

What happens if that file does not exist? Dead network in the guest?
I tend to think if a VM with PV drivers goes to sleep it has to go
through the whole suspend/resume cycle, very much like the "LID closed"
event. So I think this and the other fbdev change that is floating
around is wrong.

Olaf
