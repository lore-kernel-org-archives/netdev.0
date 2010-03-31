From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 3/6] sysfs: Implement sysfs tagged directory support.
Date: Wed, 31 Mar 2010 17:22:28 +0900
Message-ID: <4BB30644.9090809@gmail.com>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>	<1269973889-25260-3-git-send-email-ebiederm@xmission.com>	<4BB2F083.1050803@kernel.org> <m11vf12ayb.fsf@fess.ebiederm.org> <4BB30520.2030100@kernel.org>
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
In-Reply-To: <4BB30520.2030100@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just wanna add a bit more.

On 03/31/2010 05:17 PM, Tejun Heo wrote:
> If you think all those callbacks are absolute necessities, can you
> please at least add boatload of comments around them explaning what
> they're meant to do and how they're gonna be used?  It's probably
> because I don't have any experience with namespaces but I really can't
> wrap my head around it as it currently stands.

The reason why I talked about proper layering is the same reason.
It's very difficult to review your code because I have no idea how
those callbacks are meant to be used and gonna behave and that lowers
maintainability significantly in the long run.  If at all possible,
please make it implement a discrete function which is used to
implement something higher up.  If it's already done like that and I'm
just being stupid, please feel free to enlighten me.

Thanks.

-- 
tejun
