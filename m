From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH v2 03/19] vbus: add connection-client helper	infrastructure
Date: Thu, 04 Jun 2009 21:23:22 +0300
Message-ID: <4A28111A.3080000@redhat.com>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <20090409163057.32740.27829.stgit@dev.haskins.net> <20090604180611.GA16387@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <ghaskins@novell.com>,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090604180611.GA16387@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael S. Tsirkin wrote:
> Also - if we just had vmexit because a process executed
> io (or hypercall), can't we just do copy_to_user there?
> Avi, I think at some point you said that we can?
>   

You can do copy_to_user() whereever it is legal in Linux.  Almost all of 
kvm runs in process context, preemptible, and with interrupts enabled.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

