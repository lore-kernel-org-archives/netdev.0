From: Jouni Malinen <j@w1.fi>
Subject: Re: Make debug a run-time option
Date: Wed, 14 Mar 2007 17:17:42 +0000
Message-ID: <20070314171742.GA20779@hostap.isc.org>
References: <20070314160356.GA16337@athena.road.mcmartin.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: hostap@shmoo.com, netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Kyle McMartin <kyle@canonical.com>
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
Content-Disposition: inline
In-Reply-To: <20070314160356.GA16337@athena.road.mcmartin.ca>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://lists.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 14, 2007 at 12:03:56PM -0400, Kyle McMartin wrote:
> Build-time debugging isn't overly useful for distro kernel folks, nor is
> enabling huge amounts of debug spew by default. Provide the option of
> enabling debugging with module parameters.

While I understand that it would be difficult to change the debug level
options with binary distributions, I'm not sure whether I would like to
see these changes going in. PRISM2_NO_DEBUG was added to make it
possible to reduce the driver size considerably. In addition, the change
to the default debug categories (i.e., disable all) may make it more
difficult to understand reported issues. I would be more open to
disabling debug messages one-by-one if there is something specific that
can be agreed to cause more harm than benefit with extra output.

-- 
Jouni Malinen                                            PGP id EFC895FA
