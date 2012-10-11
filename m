From: Jon Stanley <jstanley@rmrf.net>
Subject: Re: regression in bonding driver with VLAN challenged interfaces when
 8021q module is loaded
Date: Thu, 11 Oct 2012 10:47:24 -0400
Message-ID: <CAJtaB1v8Zn8kwqbhD-emey6prxDyHNMUM_9sxXFMX9FkmuiNXA@mail.gmail.com>
References: <CAJtaB1v95Z2b78cKUPYrZtriF6BuHwD2=StyhV3gGOOquNt7fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jpirko@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJtaB1v95Z2b78cKUPYrZtriF6BuHwD2=StyhV3gGOOquNt7fw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 11, 2012 at 10:28 AM, Jon Stanley <jstanley@rmrf.net> wrote:

> This specifically affects IPoIB interfaces in a bond if you do a
> down/up cycle on the bond post-boot (during boot, the bonding module
> is loaded prior to the 8021q module, so everything is fine).

I hate replying to myself, but I've just been shown an instance where
it fails to come up at boot. The configuration involves tagged
Ethernet interfaces *and* IPoIB in a bond (obviously with no VLAN's on
the IPoIB bond), I probably wasn't clear on that in my original mail.
