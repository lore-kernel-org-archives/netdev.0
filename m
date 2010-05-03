From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: show stopped status in sysfs
Date: Mon, 03 May 2010 22:44:53 +0100
Message-ID: <1272923093.27948.63.camel@localhost>
References: <20100503212423.GA15998@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100503212423.GA15998@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-05-04 at 00:24 +0300, Michael S. Tsirkin wrote:
> When debugging faulty hardware (in case of virt, faulty
> emulation) I found it helpful to be able to examine
> stopped status of the interface. The following patch makes
> this visible in sysfs.
[...]

This is a per-queue attribute and should not be associated directly with
the netdev.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
