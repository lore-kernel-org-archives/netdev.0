From: Gleb Natapov <gleb@redhat.com>
Subject: Host<->guest channel interface advice needed
Date: Wed, 26 Nov 2008 14:39:19 +0200
Message-ID: <20081126123919.GC3521@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: virtualization@lists.linux-foundation.org
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

 I'd like to ask what would be the best user space interface for generic
guest<->host communication channel. The channel will be used to pass
mouse events to/from a guest or by managements software to communicate
with agents running in a guests or for something similar.

The interfaces that are being considered are netlink socket (only datagram
semantics, linux specific), new socket family or character device with
different minor number for each channel. Which one better suits for
the purpose?  Is there other kind of interface to consider? New socket
family looks like a good choice, but it would be nice to hear other
opinions before starting to work on it.

Thanks,

--
			Gleb.
