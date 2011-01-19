From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [RFC] ipv6: don't flush routes when setting loopback
	down
Date: Wed, 19 Jan 2011 20:56:32 +0100
Message-ID: <20110119195632.GA27574@midget.suse.cz>
References: <20101209.122033.183046393.davem@davemloft.net>
	<20101216132812.2d7fd885@nehalam>
	<m1mxo5tcx6.fsf@fess.ebiederm.org>
	<20101216.182656.226781473.davem@davemloft.net>
	<20110119191823.GC8442@midget.suse.cz>
	<20110119113817.0819ddf1@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jiri Bohac <jbohac@suse.cz>, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, stable@kernel.org, maheshkelkar@gmail.com,
        brian.haley@hp.com, lorenzo@google.com,
        David Miller <davem@davemloft.net>, ebiederm@xmission.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <stable-bounces@linux.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110119113817.0819ddf1@s6510>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 19, 2011 at 11:38:17AM -0800, Stephen Hemminger wrote:
> Jiri Bohac <jbohac@suse.cz> wrote:
> > I have the feeling that Eric's patch is the safest solution we
> > have so far:
> Eric's patch has other regressions, see the discussion.

What regression do you mean? I have read the whole discussion
thoroughly. You only say in one message that deleting ::1 would
propagate to routing daemons. And Eric correctly stated that
people couldn't hit this, because  deleting ::1 would break
things on its own.

Is there a real problem with Eric's fix?

Thanks,

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
