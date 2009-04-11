From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH v2 14/19] kvm: add a reset capability
Date: Sat, 11 Apr 2009 19:56:16 +0300
Message-ID: <49E0CBB0.9030105@redhat.com>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <20090409163155.32740.50340.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090409163155.32740.50340.stgit@dev.haskins.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:
> We need a way to detect if a VM is reset later in the series, so lets
> add a capability for userspace to signal a VM reset down to the kernel.
>   

As I mentioned, this won't be reliable.  It needs to be driven from 
userspace and be per-device.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

