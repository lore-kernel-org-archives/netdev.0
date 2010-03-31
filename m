From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/6] sysfs: Implement sysfs tagged directory support.
Date: Wed, 31 Mar 2010 17:17:36 +0900
Message-ID: <4BB30520.2030100@kernel.org>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>	<1269973889-25260-3-git-send-email-ebiederm@xmission.com>	<4BB2F083.1050803@kernel.org> <m11vf12ayb.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m11vf12ayb.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Eric.

On 03/31/2010 04:43 PM, Eric W. Biederman wrote:
>> Is it at all possible to implement it in properly layered manner?
>> ie. sysfs providing mechanisms for selective visibility, driver model
>> wraps it and exports it and namespace implements namespaces on top of
>> those mechanisms?
> 
> I think that is roughly what I have.

Yeah, well, in a sense.  It's all a matter of degree.

> As for the layering itself.  Down in sysfs there are only two bits
> visible.  A void * pointer that in addition to the name is what we use
> to define selective visibility.  A context that we capture when we
> mount sysfs.  Those bits are fundamental things sysfs needs to do.

Well, I guess all I wanna say is... is there *ANY* way to do it w/
less callbacks?  It's very difficult to follow what's going on for
what.

If you think all those callbacks are absolute necessities, can you
please at least add boatload of comments around them explaning what
they're meant to do and how they're gonna be used?  It's probably
because I don't have any experience with namespaces but I really can't
wrap my head around it as it currently stands.

Thanks.

-- 
tejun
